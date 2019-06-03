//
//  ListsView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 29.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class ListsView : UIView
{
    static let CELL_IDENTIFIER = "cell"
    static let HORIZONTAL_MARGIN: CGFloat = 8
    static let HEADER_HEIGHT: CGFloat = 48
    
    private var initialized: Bool = false
    
    private var flowLayout: ListsFlowLayout?
    
    private var collectionActionDelegate : ListsViewActionDelegate?
    
    public var collectionDataSource : ListsViewDataSource? {
        get {
            return playlistsCollection.dataSource as? ListsViewDataSource
        }
        set {
            playlistsCollection.dataSource = newValue
        }
    }
    
    public var onCreateButtonClickedCallback: ()->Void = {() in }
    public var onDeleteButtonClickedCallback: ()->Void = {() in }
    public var onPlaylistClickedCallback: (UInt)->Void = {(index) in }
    
    public var onQuickPlayerPlaylistButtonClickCallback: ()->Void {
        get { return quickPlayerView.onPlaylistButtonClickCallback }
        set { quickPlayerView.onPlaylistButtonClickCallback = newValue }
    }
    
    public var onQuickPlayerButtonClickCallback: (ApplicationInput)->() {
        get { return quickPlayerView.onPlayerButtonClickCallback }
        set { quickPlayerView.onPlayerButtonClickCallback = newValue }
    }
    
    public var onQuickPlayerPlayOrderButtonClickCallback: ()->Void {
        get { return quickPlayerView.onPlayOrderButtonClickCallback }
        set { quickPlayerView.onPlayOrderButtonClickCallback = newValue }
    }
    
    public var onQuickPlayerSwipeUpCallback: ()->Void {
        get { return quickPlayerView.onSwipeUpCallback }
        set { quickPlayerView.onSwipeUpCallback = newValue }
    }
    
    @IBOutlet weak var header: UIView!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var playlistsCollection: UICollectionView!
    @IBOutlet var quickPlayerView: QuickPlayerView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        quickPlayerView = QuickPlayerView.create(owner: self)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if !initialized
        {
            initialized = true
            setup()
        }
    }
    
    private func setup() {
        let guide = self
        
        // Quick player view
        addSubview(quickPlayerView)
        quickPlayerView.translatesAutoresizingMaskIntoConstraints = false
        quickPlayerView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        quickPlayerView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        quickPlayerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        quickPlayerView.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.2).isActive = true
        
        // Header
        header.translatesAutoresizingMaskIntoConstraints = false
        header.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: ListsView.HORIZONTAL_MARGIN).isActive = true
        header.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -ListsView.HORIZONTAL_MARGIN).isActive = true
        header.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        header.heightAnchor.constraint(equalToConstant: ListsView.HEADER_HEIGHT).isActive = true
        
        // Buttons
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        createButton.leftAnchor.constraint(equalTo: header.leftAnchor).isActive = true
        createButton.heightAnchor.constraint(equalToConstant: ListsView.HEADER_HEIGHT).isActive = true
        
        createButton.addTarget(self, action: #selector(actionCreateButtonClick), for: .touchUpInside)
        
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.topAnchor.constraint(equalTo: header.topAnchor).isActive = true
        deleteButton.rightAnchor.constraint(equalTo: header.rightAnchor).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: ListsView.HEADER_HEIGHT).isActive = true
        
        deleteButton.addTarget(self, action: #selector(actionDeleteButtonClick), for: .touchUpInside)
        
        // Collection
        playlistsCollection.translatesAutoresizingMaskIntoConstraints = false
        playlistsCollection.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: ListsView.HORIZONTAL_MARGIN).isActive = true
        playlistsCollection.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -ListsView.HORIZONTAL_MARGIN).isActive = true
        playlistsCollection.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 2).isActive = true
        playlistsCollection.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        let nib = UINib(nibName: String(describing: ListsItemCell.self), bundle: nil)
        playlistsCollection.register(nib, forCellWithReuseIdentifier: ListsView.CELL_IDENTIFIER)
        
        playlistsCollection.collectionViewLayout = ListsFlowLayout()
        
        self.collectionActionDelegate = ListsViewActionDelegate(view: self)
        playlistsCollection.delegate = collectionActionDelegate
    }
    
    public func updateTime(currentTime: Double, totalDuration: Double) {
        quickPlayerView.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    public func updateMediaInfo(track: AudioTrack) {
        quickPlayerView.updateMediaInfo(track: track)
    }
    
    public func updatePlayButtonState(playing: Bool) {
        quickPlayerView.updatePlayButtonState(playing: playing)
    }
    
    public func updatePlayOrderButtonState(order: AudioPlayOrder) {
        quickPlayerView.updatePlayOrderButtonState(order: order)
    }
}

// Actions
extension ListsView {
    @objc func actionCreateButtonClick() {
        self.onCreateButtonClickedCallback()
    }
    
    @objc func actionDeleteButtonClick() {
        self.onDeleteButtonClickedCallback()
    }
    
    @objc func actionPlaylistClick(index: UInt) {
        self.onPlaylistClickedCallback(index)
    }
}

// Builder
extension ListsView {
    class func create(owner: Any) -> ListsView? {
        let bundle = Bundle.main
        let nibName = String(describing: ListsView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? ListsView
    }
}

// Custom flow layout
class ListsFlowLayout : UICollectionViewFlowLayout
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

// Collection data source
class ListsViewDataSource : NSObject, UICollectionViewDataSource
{
    let audioInfo: AudioInfo
    let playlists: [AudioPlaylist]
    
    init(audioInfo: AudioInfo, playlists: [AudioPlaylist]) {
        self.audioInfo = audioInfo
        self.playlists = playlists
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlists.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchView.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? ListsItemCell else {
            return reusableCell
        }
        
        let item = playlists[indexPath.row]
        let firstTrack = item.firstTrack
        
        cell.playlistImage.image = firstTrack.albumCover?.image(at: cell.playlistImage!.frame.size)
        cell.titleLabel.text = item.name
        cell.descriptionLabel.text = getPlaylistDescription(playlist: item)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func getPlaylistDescription(playlist: AudioPlaylist) -> String {
        return Text.value(.PlaylistCellDescription, "\(playlist.tracks.count)")
    }
}

// Collection delegate
class ListsViewActionDelegate : NSObject, UICollectionViewDelegate
{
    private weak var view: ListsView?
    
    init(view: ListsView) {
        self.view = view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view?.actionPlaylistClick(index: UInt(indexPath.row))
    }
}
