//
//  CreateListView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class CreateListView : UIView
{
    public static let CELL_IDENTIFIER = "cell"
    public static let HORIZONTAL_MARGIN: CGFloat = 8
    public static let HEADER_HEIGHT: CGFloat = 48
    
    private var addedTracksCollectionDelegate : CreateListViewAddedTracksActionDelegate?
    
    public var addedTracksCollectionDataSource : CreateListViewAddedTracksDataSource? {
        get {
            return addedTracksCollection.dataSource as? CreateListViewAddedTracksDataSource
        }
        set {
            addedTracksCollection.dataSource = newValue
        }
    }
    
    private var albumsCollectionDelegate : CreateListViewAlbumsActionDelegate?
    
    public var albumsCollectionDataSource : CreateListViewAlbumsDataSource? {
        get {
            return albumsTable.dataSource as? CreateListViewAlbumsDataSource
        }
        set {
            albumsTable.dataSource = newValue
        }
    }
    
    public var onCancelButtonClickedCallback: ()->Void = {() in }
    public var onDoneButtonClickedCallback: ()->Void = {() in }
    public var onAddedTrackClickedCallback: (UInt)->Void = {(index) in }
    public var onAlbumClickedCallback: (UInt)->Void = {(index) in }
    
    @IBOutlet weak var header: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var playlistNameField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet var addedTracksLabel: UILabel!
    @IBOutlet weak var addedTracksCollection: UICollectionView!
    @IBOutlet var tracksLabel: UILabel!
    @IBOutlet weak var albumsTable: UITableView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        let guide = self.safeAreaLayoutGuide
        let entireContentSize = self.frame
        var top = self.bottomAnchor
        
        // Header
        header.translatesAutoresizingMaskIntoConstraints = false
        header.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: CreateListView.HEADER_HEIGHT).isActive = true
        header.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        header.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        
        top = header.bottomAnchor
        
        // Header buttons
        cancelButton.frame.size.width = 32
        cancelButton.addTarget(self, action: #selector(actionCancelButtonClick), for: .touchUpInside)
        
        doneButton.frame.size.width = 32
        doneButton.addTarget(self, action: #selector(actionDoneButtonClick), for: .touchUpInside)
        
        // Playlist name text field
        playlistNameField.frame.size.width = header.frame.width
        
        // Label - added tracks
        addedTracksLabel.translatesAutoresizingMaskIntoConstraints = false
        addedTracksLabel.topAnchor.constraint(equalTo: top).isActive = true
        addedTracksLabel.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        addedTracksLabel.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        
        top = addedTracksLabel.bottomAnchor
        
        // Added tracks collection
        addedTracksCollection.translatesAutoresizingMaskIntoConstraints = false
        addedTracksCollection.topAnchor.constraint(equalTo: top).isActive = true
        addedTracksCollection.heightAnchor.constraint(equalToConstant: entireContentSize.height * 0.2).isActive = true
        addedTracksCollection.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        addedTracksCollection.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        
        var nib = UINib(nibName: String(describing: CreateListAddedTrackCell.self), bundle: nil)
        addedTracksCollection.register(nib, forCellWithReuseIdentifier: CreateListView.CELL_IDENTIFIER)
        
        self.addedTracksCollectionDelegate = CreateListViewAddedTracksActionDelegate(view: self)
        addedTracksCollection.delegate = self.addedTracksCollectionDelegate
        
        addedTracksCollection.collectionViewLayout = CreateListAddedTracksFlowLayout()
        
        top = addedTracksCollection.bottomAnchor
        
        // Label - tracks
        tracksLabel.translatesAutoresizingMaskIntoConstraints = false
        tracksLabel.topAnchor.constraint(equalTo: top).isActive = true
        tracksLabel.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        tracksLabel.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        
        top = tracksLabel.bottomAnchor
        
        // Albums table
        albumsTable.translatesAutoresizingMaskIntoConstraints = false
        albumsTable.topAnchor.constraint(equalTo: top).isActive = true
        albumsTable.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        albumsTable.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        albumsTable.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        
        nib = UINib(nibName: String(describing: CreateListAlbumCell.self), bundle: nil)
        albumsTable.register(nib, forCellReuseIdentifier: CreateListView.CELL_IDENTIFIER)
        
        self.albumsCollectionDelegate = CreateListViewAlbumsActionDelegate(view: self)
        albumsTable.delegate = self.albumsCollectionDelegate
    }
    
    public func reloadData() {
        addedTracksCollection.reloadData()
        albumsTable.reloadData()
    }
    
    public func openAlbumAt(index: UInt, albumTracks: [AudioTrack]) {
        self.albumsCollectionDataSource?.selectAlbum(index: index, albumTracks: albumTracks)
        self.albumsCollectionDelegate?.selectAlbum(index: index, albumTracks: albumTracks)
        
        let at: [IndexPath] = [IndexPath(row: Int(index), section: 0)]
        
        albumsTable.reloadRows(at: at, with: .automatic)
    }
}

// Actions
extension CreateListView {
    @objc func actionCancelButtonClick() {
        self.onCancelButtonClickedCallback()
    }
    
    @objc func actionDoneButtonClick() {
        self.onDoneButtonClickedCallback()
    }
    
    @objc func actionAddedTrackClick(index: UInt) {
        self.onAddedTrackClickedCallback(index)
    }
    
    @objc func actionAlbumClick(index: UInt) {
        self.onAlbumClickedCallback(index)
    }
}

// Builder
extension CreateListView {
    class func create(owner: Any) -> CreateListView? {
        let bundle = Bundle.main
        let nibName = String(describing: CreateListView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? CreateListView
    }
}

// Collection data source
class CreateListViewAddedTracksDataSource : NSObject, UICollectionViewDataSource
{
    let audioInfo: AudioInfo
    let tracks: [AudioTrack]
    
    init(audioInfo: AudioInfo, tracks: [AudioTrack]) {
        self.audioInfo = audioInfo
        self.tracks = tracks
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: CreateListView.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? CreateListAddedTrackCell else {
            return reusableCell
        }
        
        let item = tracks[indexPath.row]
        
        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = getTrackDescription(track: item)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func getTrackDescription(track: AudioTrack) -> String {
        return track.duration
    }
}

// Custom flow layout
class CreateListAddedTracksFlowLayout : UICollectionViewFlowLayout
{
    static let CELL_SIZE = CGSize(width: 0, height: 64)
    
    init(minimumInteritemSpacing: CGFloat = 1, minimumLineSpacing: CGFloat = 1, sectionInset: UIEdgeInsets = .zero) {
        super.init()
        
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else
        {
            return
        }
        
        let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing
        
        let itemWidth = (collectionView.bounds.size.width - marginsAndInsets)
        
        itemSize = CGSize(width: itemWidth, height: ListsFlowLayout.CELL_SIZE.height)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}

// Collection action delegate
class CreateListViewAddedTracksActionDelegate : NSObject, UICollectionViewDelegate
{
    private weak var view: CreateListView?
    
    init(view: CreateListView) {
        self.view = view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view?.actionAddedTrackClick(index: UInt(indexPath.row))
    }
}

// Table data source
class CreateListViewAlbumsDataSource : NSObject, UITableViewDataSource
{
    let albums: [AudioAlbum]
    let onTrackClickedCallback: (UInt)->()
    
    private var selectedAlbumIndex: Int = -1
    private var selectedAlbumTracks: [AudioTrack] = []
    private var selectedAlbumDataSource: CreateListAlbumCellDataSource?
    
    init(albums: [AudioAlbum], onTrackClickedCallback: @escaping (UInt)->()) {
        self.albums = albums
        self.onTrackClickedCallback = onTrackClickedCallback
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: CreateListView.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? CreateListAlbumCell else {
            return reusableCell
        }
        
        let item = albums[indexPath.row]
        
        cell.coverImage.image = item.albumCover?.image(at: cell.coverImage!.frame.size)
        cell.titleLabel.text = item.albumTitle
        
        if indexPath.row == selectedAlbumIndex
        {
            cell.tracksTable.isHidden = false
            cell.onTrackClickedCallback = onTrackClickedCallback
            self.selectedAlbumDataSource = CreateListAlbumCellDataSource(tracks: selectedAlbumTracks)
            cell.tracksTable.dataSource = self.selectedAlbumDataSource
            cell.tracksTable.reloadData()
        }
        else
        {
            cell.tracksTable.isHidden = true
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func getTrackDescription(track: AudioTrack) -> String {
        return track.duration
    }
    
    public func selectAlbum(index: UInt, albumTracks: [AudioTrack]) {
        if self.selectedAlbumIndex == Int(index)
        {
            self.deselectAlbum()
            return
        }
        
        self.selectedAlbumIndex = Int(index)
        self.selectedAlbumTracks = albumTracks
    }
    
    public func deselectAlbum() {
        self.selectedAlbumIndex = -1
        self.selectedAlbumTracks = []
    }
}

// Table action delegate
class CreateListViewAlbumsActionDelegate : NSObject, UITableViewDelegate
{
    static let CELL_SIZE = CGSize(width: 0, height: 48)
    static let CELL_SELECTED_SIZE = CGSize(width: 0, height: 248)
    
    private weak var view: CreateListView?
    
    private var selectedAlbumIndex: Int = -1
    private var selectedAlbumTracksCount: UInt = 0
    
    init(view: CreateListView) {
        self.view = view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view?.actionAlbumClick(index: UInt(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Selected
        if selectedAlbumIndex == indexPath.row
        {
            return CreateListViewAlbumsActionDelegate.CELL_SELECTED_SIZE.height
        }
        
        return CreateListViewAlbumsActionDelegate.CELL_SIZE.height
    }
    
    public func selectAlbum(index: UInt, albumTracks: [AudioTrack]) {
        if self.selectedAlbumIndex == Int(index)
        {
            self.deselectAlbum()
            return
        }
        
        self.selectedAlbumIndex = Int(index)
        self.selectedAlbumTracksCount = UInt(albumTracks.count)
    }
    
    public func deselectAlbum() {
        self.selectedAlbumIndex = -1
        self.selectedAlbumTracksCount = 0
    }
}
