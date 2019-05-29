//
//  PlaylistView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class PlaylistViewDataSource : NSObject, UICollectionViewDataSource
{
    public static let HIGHLIGHT_COLOR = UIColor.yellow
    
    let audioInfo: AudioInfo
    let playlist: AudioPlaylist
    
    init(audioInfo: AudioInfo, playlist: AudioPlaylist) {
        self.audioInfo = audioInfo
        self.playlist = playlist
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerV = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                      withReuseIdentifier: PlaylistView.HEADER_IDENTIFIER,
                                                                      for: indexPath)
        
        guard let header = headerV as? PlaylistHeaderView else {
            return headerV
        }
        
        let isAlbum = playlist.isAlbumPlaylist()
        
        if isAlbum
        {
            setImage(header: header, collectionView: collectionView)
        }
        else
        {
            hideImage(header: header, collectionView: collectionView)
        }
        
        header.titleText.text = playlist.name
        
        if isAlbum
        {
            header.artistText.text = playlist.firstTrack.artist
        }
        else
        {
            header.artistText.text = ""
        }
        
        header.descriptionText.text = getPlaylistDescription()
        
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return playlist.size()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistView.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? PlaylistCell else {
            return reusableCell
        }
        
        let item = playlist.trackAt(indexPath.row)
        
        cell.titleText.text = item.title
        cell.descriptionText.text = item.duration
        cell.trackNumText.text = item.trackNum
        
        // Highlight cells that contain the currently playing track
        cell.backgroundColor = .clear
        
        if let playerPlaylist = AudioPlayer.shared.playlist
        {
            if playerPlaylist.playingTrack == item
            {
                cell.backgroundColor = PlaylistViewDataSource.HIGHLIGHT_COLOR
            }
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func getPlaylistDescription() -> String {
        var totalDuration: Double = 0
        
        for track in playlist.tracks
        {
            totalDuration += track.durationInSeconds
        }
        
        return Text.value(.ListDescription, "\(playlist.tracks.count)", "\(AudioTrack.secondsToString(totalDuration))")
    }
    
    private func setImage(header: PlaylistHeaderView, collectionView: UICollectionView) {
        if let image = playlist.firstTrack.albumCover?.image(at: header.bounds.size)
        {
            header.artCoverImage.image = image
            header.artCoverImage.frame.size = .zero
        }
        else
        {
            hideImage(header: header, collectionView: collectionView)
        }
    }
    
    private func hideImage(header: PlaylistHeaderView, collectionView: UICollectionView) {
        header.removeArtCoverImage()
        
        if let flowLayout = collectionView.collectionViewLayout as? PlaylistFlowLayout
        {
            flowLayout.headerSize = PlaylistFlowLayout.HEADER_SIZE_IMAGELESS
        }
    }
}

class PlaylistViewActionDelegate : NSObject, UICollectionViewDelegate
{
    private weak var view: PlaylistViewDelegate?

    init(view: PlaylistViewDelegate) {
        self.view = view
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view?.onTrackClicked(index: UInt(indexPath.row))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view?.onScrollDown()
    }
    
    func onSwipeRight() {
        view?.onSwipeRight()
    }
}

class PlaylistView : UIView
{
    static let CELL_IDENTIFIER = "cell"
    static let HEADER_IDENTIFIER = "header"
    static let ALBUM_TITLE_OVERLAY_HEIGHT: CGFloat = 48
    
    @IBOutlet weak var albumTitleOverlayLabel: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var quickPlayerView: QuickPlayerView!
    
    private var initialized: Bool = false
    
    private var flowLayout: PlaylistFlowLayout?
    
    private var collectionViewHeaderHeight: CGFloat = 0
    
    var collectionDataSource : PlaylistViewDataSource? {
        get {
            return collectionView.dataSource as? PlaylistViewDataSource
        }
        set {
            collectionView.dataSource = newValue
        }
    }
    
    var collectionActionDelegate : PlaylistViewActionDelegate? {
        get {
            return collectionView.delegate as? PlaylistViewActionDelegate
        }
        set {
            collectionView.delegate = newValue
        }
    }
    
    var quickPlayerDelegate : BaseViewController? {
        get {
            return quickPlayerView.delegate
        }
        set {
            quickPlayerView.delegate = newValue
        }
    }
    
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
        let guide = self.superview!
        
        // Quick player view
        addSubview(quickPlayerView)
        quickPlayerView.translatesAutoresizingMaskIntoConstraints = false
        quickPlayerView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        quickPlayerView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        quickPlayerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        quickPlayerView.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.2).isActive = true
        
        // Collection view
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        let cellNib = UINib(nibName: String(describing: PlaylistCell.self), bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: PlaylistView.CELL_IDENTIFIER)
        
        let headerNib = UINib(nibName: String(describing: PlaylistHeaderView.self), bundle: nil)
        collectionView.register(headerNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PlaylistView.HEADER_IDENTIFIER)
        
        flowLayout = PlaylistFlowLayout(collectionView: collectionView)
        
        collectionView.collectionViewLayout = flowLayout!
        
        // Album title overlay label
        albumTitleOverlayLabel.translatesAutoresizingMaskIntoConstraints = false
        albumTitleOverlayLabel.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        albumTitleOverlayLabel.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        albumTitleOverlayLabel.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        albumTitleOverlayLabel.heightAnchor.constraint(equalToConstant: PlaylistView.ALBUM_TITLE_OVERLAY_HEIGHT).isActive = true
        
        // User input
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(actionSwipeRight(gesture:)))
        gesture.direction = .right
        self.addGestureRecognizer(gesture)
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
    
    public func scrollDownToSelectedTrack(index: UInt) {
        DispatchQueue.main.async {
            self.collectionView.layoutIfNeeded()
            self.collectionView.scrollToItem(at: IndexPath(row: Int(index), section: 0), at: .centeredVertically, animated: false)
        }
    }
    
    func updateTime(currentTime: Double, totalDuration: Double) {
        quickPlayerView.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    func updateMediaInfo(track: AudioTrack) {
        quickPlayerView.updateMediaInfo(track: track)
        
        reloadData()
    }
    
    func updatePlayButtonState(playing: Bool) {
        quickPlayerView.updatePlayButtonState(playing: playing)
    }
    
    func updatePlayOrderButtonState(order: AudioPlayOrder) {
        quickPlayerView.updatePlayOrderButtonState(order: order)
    }
    
    func updateOverlayTitle(title: String) {
        albumTitleOverlayLabel.text = title
    }
    
    func showAlbumTitleOverlay() {
        if albumTitleOverlayLabel.alpha == 0
        {
            UIAnimations.animateViewFadeIn(albumTitleOverlayLabel)
        }
    }
    
    func hideAlbumTitleOverlay() {
        if albumTitleOverlayLabel.alpha == 1
        {
            UIAnimations.animateViewFadeOut(albumTitleOverlayLabel)
        }
    }
    
    func updateScrollState() {
        if collectionViewHeaderHeight == 0
        {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                         withReuseIdentifier: PlaylistView.HEADER_IDENTIFIER,
                                                                         for: IndexPath(row: 0, section: 0))
            self.collectionViewHeaderHeight = header.frame.height
        }
        
        if collectionView.bounds.origin.y > collectionViewHeaderHeight
        {
            showAlbumTitleOverlay()
        }
        else
        {
            hideAlbumTitleOverlay()
        }
    }
}

// Actions
extension PlaylistView {
    @objc func actionSwipeRight(gesture: UISwipeGestureRecognizer) {
        self.collectionActionDelegate?.onSwipeRight()
    }
}

// Builder
extension PlaylistView {
    class func create(owner: Any) -> PlaylistView? {
        let bundle = Bundle.main
        let nibName = String(describing: PlaylistView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? PlaylistView
    }
}

class PlaylistFlowLayout : UICollectionViewFlowLayout
{
    static let CELL_SIZE = CGSize(width: 0, height: 48)
    static let HEADER_SIZE = CGSize(width: 0, height: 224)
    static let HEADER_SIZE_IMAGELESS = CGSize(width: 0, height: 64)
    
    public var headerSize: CGSize {
        get {
            return self.headerReferenceSize
        }
        
        set {
            if self.headerReferenceSize != newValue
            {
                self.headerReferenceSize = newValue
                
                self.invalidateLayout()
            }
        }
    }
    
    init(collectionView: UICollectionView, minimumInteritemSpacing: CGFloat = 0, minimumLineSpacing: CGFloat = 1, sectionInset: UIEdgeInsets = .zero) {
        super.init()
        
        self.minimumInteritemSpacing = minimumInteritemSpacing
        self.minimumLineSpacing = minimumLineSpacing
        self.sectionInset = sectionInset
        
        self.headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: PlaylistFlowLayout.HEADER_SIZE.height)
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
        
        itemSize = CGSize(width: itemWidth, height: PlaylistFlowLayout.CELL_SIZE.height)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
