//
//  CreateListView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

struct CreateListAudioTrack
{
    public let title: String
    public let description: String
    private let identifier: String
    
    init(title: String, description: String, identifier: String) {
        self.title = title
        self.description = description
        self.identifier = identifier
    }
    
    public static func createFrom(_ track: BaseAudioTrack) -> CreateListAudioTrack {
        return CreateListAudioTrack(title: track.title, description: track.duration, identifier: track.filePath.absoluteString)
    }
    
    static func ==(lhs: CreateListAudioTrack, rhs: CreateListAudioTrack) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public func equalsToTrack(_ track: BaseAudioTrack) -> Bool {
        return identifier == track.filePath.absoluteString
    }
}

class CreateListView : UIView
{
    public static let HORIZONTAL_MARGIN: CGFloat = 8
    public static let HEADER_HEIGHT: CGFloat = 48
    
    private var openedAlbum: CreateListAlbumCell?
    
    private var addedTracksTableDelegate : BaseCreateListViewAddedTracksActionDelegate?
    
    public var addedTracksTableDataSource : BaseCreateListViewAddedTracksTableDataSource? {
        get {
            return addedTracksTable.dataSource as? BaseCreateListViewAddedTracksTableDataSource
        }
        set {
            addedTracksTable.dataSource = newValue
        }
    }
    
    private var albumsTableDelegate : BaseCreateListViewAlbumsDelegate?
    
    public var albumsTableDataSource : BaseCreateListViewAlbumsDataSource? {
        get {
            return albumsTable.dataSource as? BaseCreateListViewAlbumsDataSource
        }
        set {
            albumsTable.dataSource = newValue
        }
    }
    
    public var onTextFieldEditedCallback: (String)->Void = {(text) in }
    public var onCancelButtonClickedCallback: ()->Void = {() in }
    public var onDoneButtonClickedCallback: ()->Void = {() in }
    public var onAddedTrackClickedCallback: (UInt)->Void = {(index) in }
    public var onAlbumClickedCallback: (UInt)->Void = {(index) in }
    
    @IBOutlet weak var header: UIStackView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var playlistNameField: UITextField!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var addedTracksLabel: UILabel!
    @IBOutlet weak var addedTracksTable: UITableView!
    @IBOutlet weak var tracksLabel: UILabel!
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
        
        // App theme setup
        setupAppTheme()
        
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
        playlistNameField.delegate = self
        playlistNameField.addTarget(self, action: #selector(actionTextFieldChanged(_:)), for: .editingChanged)
        
        // Label - added tracks
        addedTracksLabel.translatesAutoresizingMaskIntoConstraints = false
        addedTracksLabel.topAnchor.constraint(equalTo: top).isActive = true
        addedTracksLabel.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        addedTracksLabel.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        
        top = addedTracksLabel.bottomAnchor
        
        // Added tracks collection
        addedTracksTable.translatesAutoresizingMaskIntoConstraints = false
        addedTracksTable.topAnchor.constraint(equalTo: top).isActive = true
        addedTracksTable.heightAnchor.constraint(equalToConstant: entireContentSize.height * 0.2).isActive = true
        addedTracksTable.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: CreateListView.HORIZONTAL_MARGIN).isActive = true
        addedTracksTable.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -CreateListView.HORIZONTAL_MARGIN).isActive = true
        
        addedTracksTable.separatorStyle = .none
        
        var nib = UINib(nibName: String(describing: CreateListAddedTrackCell.self), bundle: nil)
        addedTracksTable.register(nib, forCellReuseIdentifier: CreateListAddedTrackCell.CELL_IDENTIFIER)
        
        self.addedTracksTableDelegate = CreateListViewAddedTracksActionDelegate(view: self)
        addedTracksTable.delegate = self.addedTracksTableDelegate
        
        top = addedTracksTable.bottomAnchor
        
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
        albumsTable.register(nib, forCellReuseIdentifier: CreateListAlbumCell.CELL_IDENTIFIER)
        
        self.albumsTableDelegate = CreateListViewAlbumsDelegate(view: self)
        albumsTable.delegate = self.albumsTableDelegate
    }
    
    public func setupAppTheme() {
        self.backgroundColor = AppTheme.shared.colorFor(.STANDART_BACKGROUND)
        
        addedTracksTable.backgroundColor = .clear
        albumsTable.backgroundColor = .clear
        addedTracksLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        tracksLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        
        cancelButton.tintColor = AppTheme.shared.colorFor(.STANDART_BUTTON)
        doneButton.tintColor = AppTheme.shared.colorFor(.STANDART_BUTTON)
        
        addedTracksTable.indicatorStyle = AppTheme.shared.scrollBarColor()
        albumsTable.indicatorStyle = AppTheme.shared.scrollBarColor()
    }
    
    public func reloadAddedTracksData() {
        addedTracksTable.reloadData()
    }
    
    public func reloadAlbumsData() {
        albumsTable.reloadData()
    }
    
    public func openAlbumAt(index: UInt,
                            albumTracks: [CreateListAudioTrack],
                            addedTracks: [CreateListAudioTrack]) {
        self.albumsTableDataSource?.openAlbum(index: index, albumTracks: albumTracks, addedTracks: addedTracks)
        self.albumsTableDelegate?.selectAlbum(index: index, albumTracks: albumTracks)
        
        albumsTable.reloadRows(at: [IndexPath(row: Int(index), section: 0)], with: .automatic)
    }
    
    public func deselectTrackFromOpenedAlbum(_ albumTrack: CreateListAudioTrack) {
        self.albumsTableDataSource?.deselectAlbumTrack(albumTrack)
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
    
    @objc func actionTextFieldChanged(_ textField: UITextField) {
        if let text = textField.text
        {
            self.onTextFieldEditedCallback(text)
        }
    }
}

// Text field actions
extension CreateListView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let text = textField.text
        {
            self.onTextFieldEditedCallback(text)
        }
        
        return true
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

// Table data source
class CreateListViewAddedTracksTableDataSource : NSObject, BaseCreateListViewAddedTracksTableDataSource
{
    let audioInfo: AudioInfo
    let tracks: [BaseAudioTrack]
    
    init(audioInfo: AudioInfo, tracks: [BaseAudioTrack]) {
        self.audioInfo = audioInfo
        self.tracks = tracks
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: CreateListAddedTrackCell.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? CreateListAddedTrackCell else {
            return reusableCell
        }
        
        let item = tracks[indexPath.row]
        
        cell.coverImage.image = item.albumCoverImage
        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = getTrackDescription(track: item)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func getTrackDescription(track: BaseAudioTrack) -> String {
        return track.duration
    }
}

// Table action delegate
class CreateListViewAddedTracksActionDelegate : NSObject, BaseCreateListViewAddedTracksActionDelegate
{
    private weak var view: CreateListView?
    
    init(view: CreateListView) {
        self.view = view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view?.actionAddedTrackClick(index: UInt(indexPath.row))
    }
}

// Table data source
class CreateListViewAlbumsDataSource : NSObject, BaseCreateListViewAlbumsDataSource
{
    let albums: [AudioAlbum]
    let onOpenedAlbumTrackSelectionCallback: (UInt)->()
    let onOpenedAlbumTrackDeselectionCallback: (UInt)->()
    
    private var selectedAlbumIndex: Int = -1
    private var selectedAlbumCell: CreateListAlbumCell?
    private var selectedAlbumTracks: [CreateListAudioTrack] = []
    private var selectedAlbumDataSource: BaseCreateListAlbumCellDataSource?
    
    private var addedTracks: [CreateListAudioTrack] = []
    
    init(albums: [AudioAlbum],
         onOpenedAlbumTrackSelectionCallback: @escaping (UInt)->(),
         onOpenedAlbumTrackDeselectionCallback: @escaping (UInt)->()) {
        self.albums = albums
        self.onOpenedAlbumTrackSelectionCallback = onOpenedAlbumTrackSelectionCallback
        self.onOpenedAlbumTrackDeselectionCallback = onOpenedAlbumTrackDeselectionCallback
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: CreateListAlbumCell.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? CreateListAlbumCell else {
            return reusableCell
        }
        
        let item = albums[indexPath.row]
        
        cell.coverImage.image = item.albumCoverImage
        cell.titleLabel.text = item.albumTitle
        
        // Selected album - display, update callbacks and update table data source
        if indexPath.row == selectedAlbumIndex
        {
            self.selectedAlbumCell = cell
            
            cell.tracksTable.isHidden = false
            
            cell.onOpenedAlbumTrackSelectionCallback = onOpenedAlbumTrackSelectionCallback
            cell.onOpenedAlbumTrackDeselectionCallback = onOpenedAlbumTrackDeselectionCallback
            
            self.selectedAlbumDataSource = CreateListAlbumCellDataSource(tracks: selectedAlbumTracks)
            cell.tracksTable.dataSource = self.selectedAlbumDataSource
            cell.tracksTable.reloadData()
            
            updateSelectedAlbumTracks()
        }
        else
        {
            cell.tracksTable.isHidden = true
            cell.tracksTable.dataSource = nil
            
            cell.onOpenedAlbumTrackSelectionCallback = {(index)->() in }
            cell.onOpenedAlbumTrackDeselectionCallback = {(index)->() in }
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func getTrackDescription(track: BaseAudioTrack) -> String {
        return track.duration
    }
    
    public func openAlbum(index: UInt, albumTracks: [CreateListAudioTrack], addedTracks: [CreateListAudioTrack]) {
        if self.selectedAlbumIndex == Int(index)
        {
            self.closeAlbum()
            return
        }
        
        self.selectedAlbumIndex = Int(index)
        self.selectedAlbumCell = nil
        self.selectedAlbumTracks = albumTracks
        self.addedTracks = addedTracks
    }
    
    public func closeAlbum() {
        self.selectedAlbumIndex = -1
        self.selectedAlbumCell = nil
        self.selectedAlbumTracks = []
        self.addedTracks = []
    }
    
    private func updateSelectedAlbumTracks() {
        guard let selectedAlbum = self.selectedAlbumCell else {
            return
        }
        
        for e in 0..<addedTracks.count
        {
            let trackToSelect = addedTracks[e]
            
            // Find the corresponding index
            for i in 0..<selectedAlbumTracks.count
            {
                let albumTrack = selectedAlbumTracks[i]
                
                if albumTrack == trackToSelect
                {
                    selectedAlbum.selectAlbumTrack(at: UInt(i))
                }
            }
        }
    }
    
    public func deselectAlbumTrack(_ track: CreateListAudioTrack) {
        guard let selectedAlbum = self.selectedAlbumCell else {
            return
        }
        
        for e in 0..<selectedAlbumTracks.count
        {
            let albumTrack = selectedAlbumTracks[e]
            
            if albumTrack == track
            {
                selectedAlbum.deselectAlbumTrack(at: UInt(e))
                break
            }
        }
    }
}

// Table action delegate
class CreateListViewAlbumsDelegate : NSObject, BaseCreateListViewAlbumsDelegate
{
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
        if selectedAlbumIndex == indexPath.row
        {
            return CreateListAlbumCell.SELECTED_SIZE.height
        }
        
        return CreateListAlbumCell.SIZE.height
    }
    
    public func selectAlbum(index: UInt, albumTracks: [CreateListAudioTrack]) {
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

// Table data source
class CreateListAlbumCellDataSource : NSObject, BaseCreateListAlbumCellDataSource
{
    let tracks: [CreateListAudioTrack]
    
    init(tracks: [CreateListAudioTrack]) {
        self.tracks = tracks
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: CreateListAlbumCell.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? CreateListAlbumTrackCell else {
            return reusableCell
        }
        
        let item = tracks[indexPath.row]
        
        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = item.description
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// Table delegate
class CreateListAlbumCellDelegate : NSObject, BaseCreateListAlbumCellDelegate
{
    private weak var view: CreateListAlbumCell?
    
    init(view: CreateListAlbumCell) {
        self.view = view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view?.actionOnTrackSelection(UInt(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.view?.actionOnTrackDeselection(UInt(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CreateListAlbumTrackCell.HEIGHT
    }
}
