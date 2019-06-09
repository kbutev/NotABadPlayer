//
//  AlbumsTableView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 30.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class AlbumsView : UIView
{
    public static let CELL_IDENTIFIER = "cell"
    public static let CELLS_PER_COLUMN: Int = 2
    public static let INDEXER_VIEW_WIDTH: CGFloat = 16
    public static let COLLECTION_HORIZONTAL_MARGIN: CGFloat = INDEXER_VIEW_WIDTH
    
    private var initialized: Bool = false
    
    private var collectionIndexerView: CollectionIndexerView!
    
    private var flowLayout: AlbumsFlowLayout?
    
    private var collectionActionDelegate : AlbumsViewActionDelegate?
    
    public var collectionDataSource : AlbumsViewDataSource? {
        get {
            return collectionView.dataSource as? AlbumsViewDataSource
        }
        set {
            collectionView.dataSource = newValue
        }
    }
    
    public var collectionDelegate : AlbumsViewActionDelegate? {
        get {
            return collectionView.delegate as? AlbumsViewActionDelegate
        }
        set {
            collectionView.delegate = newValue
        }
    }
    
    public var onAlbumClickCallback: (UInt)->Void = {(index) in }
    
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
    
    @IBOutlet private var collectionView: UICollectionView!
    @IBOutlet private weak var indexerCenterCharacter: UILabel!
    @IBOutlet private var quickPlayerView: QuickPlayerView!
    
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
        collectionIndexerView = CollectionIndexerView()
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
        
        // Quick player setup
        addSubview(quickPlayerView)
        quickPlayerView.translatesAutoresizingMaskIntoConstraints = false
        quickPlayerView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        quickPlayerView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        quickPlayerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        quickPlayerView.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.2).isActive = true
        
        // Collection setup
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: AlbumsView.COLLECTION_HORIZONTAL_MARGIN).isActive = true
        collectionView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -AlbumsView.COLLECTION_HORIZONTAL_MARGIN).isActive = true
        collectionView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        let nib = UINib(nibName: String(describing: AlbumsCell.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: AlbumsView.CELL_IDENTIFIER)
        
        collectionView.collectionViewLayout = AlbumsFlowLayout(cellsPerColumn: AlbumsView.CELLS_PER_COLUMN)
        
        self.collectionActionDelegate = AlbumsViewActionDelegate(view: self)
        collectionView.delegate = collectionActionDelegate
        
        // Indexer view setup
        collectionIndexerView.delegate = self
        self.addSubview(collectionIndexerView)
        
        collectionIndexerView.translatesAutoresizingMaskIntoConstraints = false
        collectionIndexerView.widthAnchor.constraint(equalToConstant: AlbumsView.INDEXER_VIEW_WIDTH).isActive = true
        collectionIndexerView.heightAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
        collectionIndexerView.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
        collectionIndexerView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        
        // Indexer center character setup
        indexerCenterCharacter.translatesAutoresizingMaskIntoConstraints = false
        indexerCenterCharacter.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        indexerCenterCharacter.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
        indexerCenterCharacter.widthAnchor.constraint(equalToConstant: 96).isActive = true
        indexerCenterCharacter.heightAnchor.constraint(equalToConstant: 96).isActive = true
    }
    
    public func setupAppTheme() {
        self.backgroundColor = AppTheme.shared.colorFor(.STANDART_BACKGROUND)
        
        collectionView.backgroundColor = .clear
    }
    
    public func reloadData() {
        collectionView.reloadData()
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
    
    public func updateIndexerAlphabet(albumTitles: [String]) {
        collectionIndexerView?.setAlphabet(albumTitles)
    }
    
    public func jumpToItem(selection: CollectionIndexerSelection) {
        var index = Int(selection.index)
        
        if index >= collectionView.numberOfItems(inSection: 0)
        {
            index = collectionView.numberOfItems(inSection: 0) - 1
        }
        
        let path = IndexPath(item: index, section: 0)
        
        collectionView.scrollToItem(at: path, at: .top, animated: false)
    }
    
    public func showIndexerCenterCharacter(character: Character) {
        indexerCenterCharacter.text = String(character)
        
        UIAnimations.stopAnimations(indexerCenterCharacter)
        indexerCenterCharacter.alpha = 1
    }
    
    public func hideIndexerCenterCharacter() {
        UIAnimations.animateViewFadeOut(indexerCenterCharacter)
    }
}

// Actions
extension AlbumsView {
    @objc func actionAlbumClick(index: UInt) {
        self.onAlbumClickCallback(index)
    }
}

// Indexer delegate
extension AlbumsView : CollectionIndexerDelegate {
    func onTouchGestureBegin(selection: CollectionIndexerSelection) {
        // Jump to location
        jumpToItem(selection: selection)
        
        // Display character
        showIndexerCenterCharacter(character: selection.character)
    }
    
    func onTouchGestureMove(selection: CollectionIndexerSelection) {
        // Jump to location
        jumpToItem(selection: selection)
        
        // Display character
        showIndexerCenterCharacter(character: selection.character)
    }
    
    func onTouchGestureEnd(selection: CollectionIndexerSelection) {
        // Hide character
        hideIndexerCenterCharacter()
    }
}

// Builder
extension AlbumsView {
    class func create(owner: Any) -> AlbumsView? {
        let bundle = Bundle.main
        let nibName = String(describing: AlbumsView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? AlbumsView
    }
}

// Collection data source
class AlbumsViewDataSource : NSObject, UICollectionViewDataSource
{
    let audioInfo: AudioInfo
    let albums: [AudioAlbum]
    
    init(audioInfo: AudioInfo, albums: [AudioAlbum]) {
        self.audioInfo = audioInfo
        self.albums = albums
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumsView.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? AlbumsCell else {
            return reusableCell
        }
        
        let item = albums[indexPath.row]
        
        cell.covertArtImage.image = item.albumCover?.image(at: cell.covertArtImage!.frame.size)
        cell.titleText.text = item.albumTitle
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

// Collection delegate
class AlbumsViewActionDelegate : NSObject, UICollectionViewDelegate
{
    private weak var view: AlbumsView?
    
    init(view: AlbumsView) {
        self.view = view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view?.actionAlbumClick(index: UInt(indexPath.row))
    }
}

// Collection flow layout
class AlbumsFlowLayout : UICollectionViewFlowLayout
{
    let cellsPerColumn: Int
    
    init(cellsPerColumn: Int, minimumInteritemSpacing: CGFloat = 1, minimumLineSpacing: CGFloat = 1, sectionInset: UIEdgeInsets = .zero) {
        self.cellsPerColumn = cellsPerColumn
        
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
        
        let marginsAndInsets = sectionInset.left + sectionInset.right + collectionView.safeAreaInsets.left + collectionView.safeAreaInsets.right + minimumInteritemSpacing * CGFloat(cellsPerColumn - 1)
        
        let itemWidth = ((collectionView.bounds.size.width - marginsAndInsets) / CGFloat(cellsPerColumn)).rounded(.down)
        
        itemSize = CGSize(width: itemWidth, height: AlbumsCell.SIZE.height)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
