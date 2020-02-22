//
//  PlaylistView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class PlaylistView : UIView
{
    public static let SHINY_STAR_IMAGE = "shiny_star"
    public static let FAVORITES_ICON_SIZE = CGRect(x: 0, y: 1, width: 12, height: 12)
    static let HEADER_IDENTIFIER = "header"
    static let ALBUM_TITLE_OVERLAY_HEIGHT: CGFloat = 48
    
    private var initialized: Bool = false
    
    private var flowLayout: PlaylistFlowLayout?
    
    public var collectionActionDelegate: BasePlaylistViewActionDelegate?
    
    public var collectionDataSource : BasePlaylistViewDataSource? {
        get {
            return collectionView.dataSource as? BasePlaylistViewDataSource
        }
        set {
            newValue?.favoritesChecker = self.favoritesChecker
            collectionView.dataSource = newValue
        }
    }
    
    public weak var favoritesChecker : BasePlaylistFavoritesChecker? {
        get {
            return (collectionView.dataSource as? BasePlaylistViewDataSource)?.favoritesChecker
        }
        set {
            (collectionView.dataSource as? BasePlaylistViewDataSource)?.favoritesChecker = newValue
        }
    }
    
    public var onTrackClickedCallback: (UInt)->Void = {(index) in }
    public var onSwipeRightCallback: ()->Void = {() in }
    
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
    
    @IBOutlet weak var albumTitleOverlayLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    var quickPlayerView: QuickPlayerView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        self.quickPlayerView = QuickPlayerView.create(owner: self)
        self.collectionActionDelegate = PlaylistViewActionDelegate(view: self)
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
        
        // App theme setup
        setupAppTheme()
        
        // Self setup
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: superview!.leftAnchor).isActive = true
        self.rightAnchor.constraint(equalTo: superview!.rightAnchor).isActive = true
        self.topAnchor.constraint(equalTo: superview!.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: superview!.bottomAnchor).isActive = true
        
        // Quick player setup
        addSubview(quickPlayerView)
        quickPlayerView.translatesAutoresizingMaskIntoConstraints = false
        quickPlayerView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        quickPlayerView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        quickPlayerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        quickPlayerView.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.2).isActive = true
        
        // Collection setup
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        collectionView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        collectionView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        let cellNib = UINib(nibName: String(describing: PlaylistItemCell.self), bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: PlaylistItemCell.CELL_IDENTIFIER)
        
        let headerNib = UINib(nibName: String(describing: PlaylistHeaderView.self), bundle: nil)
        collectionView.register(headerNib,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: PlaylistView.HEADER_IDENTIFIER)
        
        flowLayout = PlaylistFlowLayout(collectionView: collectionView)
        
        collectionView.collectionViewLayout = flowLayout!
        
        collectionView.delegate = collectionActionDelegate
        
        collectionView.showsVerticalScrollIndicator = false
        
        // Album title overlay setup
        albumTitleOverlayLabel.translatesAutoresizingMaskIntoConstraints = false
        albumTitleOverlayLabel.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        albumTitleOverlayLabel.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        albumTitleOverlayLabel.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        albumTitleOverlayLabel.heightAnchor.constraint(equalToConstant: PlaylistView.ALBUM_TITLE_OVERLAY_HEIGHT).isActive = true
        
        // User input setup
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(actionSwipeRight(gesture:)))
        gesture.direction = .right
        self.addGestureRecognizer(gesture)
    }
    
    public func setupAppTheme() {
        self.backgroundColor = AppTheme.shared.colorFor(.STANDART_BACKGROUND)
        
        collectionView.backgroundColor = .clear
        albumTitleOverlayLabel.textColor = AppTheme.shared.colorFor(.QUICK_PLAYER_TEXT)
        albumTitleOverlayLabel.backgroundColor = AppTheme.shared.colorFor(.QUICK_PLAYER_BACKGROUND)
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
    
    public func updateOverlayTitle(title: String) {
        albumTitleOverlayLabel.text = title
    }
    
    public func showAlbumTitleOverlay() {
        if albumTitleOverlayLabel.alpha == 0
        {
            UIAnimations.animateViewFadeIn(albumTitleOverlayLabel)
        }
    }
    
    public func hideAlbumTitleOverlay() {
        if albumTitleOverlayLabel.alpha == 1
        {
            UIAnimations.animateViewFadeOut(albumTitleOverlayLabel)
        }
    }
    
    public func updateScrollState() {
        if let dataSource = collectionDataSource
        {
            if dataSource.headerSize.height != 0
            {
                if collectionView.bounds.origin.y > dataSource.headerSize.height
                {
                    showAlbumTitleOverlay()
                }
                else
                {
                    hideAlbumTitleOverlay()
                }
            }
        }
    }
    
    public func playSelectionAnimation(reloadData: Bool) {
        collectionDataSource?.playSelectionAnimation()
        
        if reloadData
        {
            self.reloadData()
        }
    }
}

// QuickPlayerObserver
extension PlaylistView: QuickPlayerObserver {
    func updateTime(currentTime: Double, totalDuration: Double) {
        quickPlayerView.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    func updateMediaInfo(track: BaseAudioTrack) {
        quickPlayerView.updateMediaInfo(track: track)
        
        reloadData()
    }
    
    func updatePlayButtonState(isPlaying: Bool) {
        quickPlayerView.updatePlayButtonState(isPlaying: isPlaying)
    }
    
    func updatePlayOrderButtonState(order: AudioPlayOrder) {
        quickPlayerView.updatePlayOrderButtonState(order: order)
    }
    
    func onVolumeChanged(volume: Double) {
        
    }
}

// Actions
extension PlaylistView {
    @objc func actionTrackClicked(index: UInt) {
        self.onTrackClickedCallback(index)
    }
    
    @objc func actionSwipeRight(gesture: UIGestureRecognizer) {
        self.onSwipeRightCallback()
    }
    
    @objc func actionScreenScrollDown() {
        self.updateScrollState()
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

// Collection data source
class PlaylistViewDataSource : NSObject, BasePlaylistViewDataSource
{
    public weak var favoritesChecker : BasePlaylistFavoritesChecker?
    
    private let audioInfo: AudioInfo
    private let playlist: BaseAudioPlaylist
    private let options: OpenPlaylistOptions
    
    private(set) var headerSize: CGSize = .zero
    
    private var playSelectionAnimationNextTime: Bool = false
    
    init(audioInfo: AudioInfo, playlist: BaseAudioPlaylist, options: OpenPlaylistOptions) {
        self.audioInfo = audioInfo
        self.playlist = playlist
        self.options = options
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let headerV = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader,
                                                                      withReuseIdentifier: PlaylistView.HEADER_IDENTIFIER,
                                                                      for: IndexPath(row: 0, section: 0))
        
        guard let header = headerV as? PlaylistHeaderView else {
            return headerV
        }
        
        headerSize = header.frame.size
        
        if !options.displayHeader {
            hideImage(header: header, collectionView: collectionView)
            return header
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
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistItemCell.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? PlaylistItemCell else {
            return reusableCell
        }
        
        let item = playlist.trackAt(indexPath.row)
        let isFavorite = favoritesChecker?.isMarkedFavorite(item: item) ?? false
        
        cell.updateTitleText(item.title)
        
        let durationText = options.displayDescriptionDuration ? item.duration : nil
        let albumTitleText = options.displayDescriptionAlbumTitle ? item.albumTitle : nil
        
        cell.updateDescriptionText(isFavorite: isFavorite, duration: durationText, albumTitle: albumTitleText)
        
        if options.displayTrackNumber {
            cell.showTrackNum()
            cell.setTrackNum(item.trackNum)
        } else {
            cell.hideTrackNum()
        }
        
        // Highlight cells that represent the currently playing track
        if let playerPlaylist = AudioPlayerService.shared.playlist
        {
            if playerPlaylist.playingTrack == item
            {
                cell.backgroundColor = AppTheme.shared.colorFor(.PLAYLIST_PLAYING_TRACK)
                
                if playSelectionAnimationNextTime
                {
                    playSelectionAnimationNextTime = false
                    UIAnimations.animateListItemClicked(cell)
                }
            }
            else
            {
                cell.backgroundColor = .clear
            }
        }
        else
        {
            cell.backgroundColor = .clear
        }
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    private func getPlaylistDescription() -> String {
        var totalDuration: Double = 0
        
        for track in playlist.tracks
        {
            totalDuration += track.durationInSeconds
        }
        
        return Text.value(.ListDescription, "\(playlist.tracks.count)", "\(StringUtilities.secondsToString(totalDuration))")
    }
    
    private func setImage(header: PlaylistHeaderView, collectionView: UICollectionView) {
        if let image = playlist.firstTrack.albumCoverImage
        {
            header.setArtCoverImage(image)
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
            flowLayout.headerSize = PlaylistHeaderView.HEADER_SIZE_IMAGELESS
        }
    }
    
    public func playSelectionAnimation() {
        self.playSelectionAnimationNextTime = true
    } 
}

// Collection delegate
class PlaylistViewActionDelegate : NSObject, BasePlaylistViewActionDelegate
{
    private weak var view: PlaylistView?
    
    private let backgroundSelectionView = UIView()
    
    init(view: PlaylistView) {
        self.view = view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        view?.playSelectionAnimation(reloadData: false)
        
        view?.actionTrackClicked(index: UInt(indexPath.row))
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view?.actionScreenScrollDown()
    }
}

// Collection flow layout
class PlaylistFlowLayout : UICollectionViewFlowLayout
{
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
        
        self.headerReferenceSize = CGSize(width: collectionView.frame.size.width, height: PlaylistHeaderView.HEADER_SIZE.height)
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
        
        itemSize = CGSize(width: itemWidth, height: PlaylistItemCell.SIZE.height)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
