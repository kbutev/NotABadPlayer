//
//  AlbumsTableView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 30.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

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
        
        cell.covertArtImage.image = item.albumCover?.image(at: AlbumsFlowLayout.CELL_SIZE)
        cell.titleText.text = item.albumTitle
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
}

class AlbumsViewActionDelegate : NSObject, UICollectionViewDelegate
{
    private weak var view: AlbumsViewDelegate?
    
    init(view: AlbumsViewDelegate) {
        self.view = view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view?.onAlbumClick(index: UInt(indexPath.row))
    }
}

class AlbumsView : UIView
{
    static let CELL_IDENTIFIER = "cell"
    static let CELLS_PER_COLUMN: Int = 2
    static let INDEXER_VIEW_WIDTH: CGFloat = 16
    static let COLLECTION_VIEW_HORIZONTAL_MARGIN: CGFloat = INDEXER_VIEW_WIDTH
    
    private var initialized: Bool = false
    
    @IBOutlet var collectionView: UICollectionView!
    var collectionIndexerView: CollectionIndexerView?
    @IBOutlet weak var indexerCenterCharacter: UILabel!
    @IBOutlet var quickPlayerView: QuickPlayerView!
    
    private var flowLayout: AlbumsFlowLayout?
    
    var collectionDataSource : AlbumsViewDataSource? {
        get {
            return collectionView.dataSource as? AlbumsViewDataSource
        }
        set {
            collectionView.dataSource = newValue
        }
    }
    
    var collectionDelegate : AlbumsViewActionDelegate? {
        get {
            return collectionView.delegate as? AlbumsViewActionDelegate
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
        let guide = self
        
        // Quick player view
        addSubview(quickPlayerView)
        quickPlayerView.translatesAutoresizingMaskIntoConstraints = false
        quickPlayerView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        quickPlayerView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        quickPlayerView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        quickPlayerView.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.2).isActive = true
        
        // Collection view
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: AlbumsView.COLLECTION_VIEW_HORIZONTAL_MARGIN).isActive = true
        collectionView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -AlbumsView.COLLECTION_VIEW_HORIZONTAL_MARGIN).isActive = true
        collectionView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        let nib = UINib(nibName: String(describing: AlbumsCell.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: AlbumsView.CELL_IDENTIFIER)
        
        collectionView.collectionViewLayout = AlbumsFlowLayout(cellsPerColumn: AlbumsView.CELLS_PER_COLUMN)
        
        // Indexer view initialize and setup
        collectionIndexerView = CollectionIndexerView()
        
        if let indexerView = collectionIndexerView
        {
            indexerView.delegate = self
            self.addSubview(indexerView)
            
            indexerView.translatesAutoresizingMaskIntoConstraints = false
            indexerView.widthAnchor.constraint(equalToConstant: AlbumsView.INDEXER_VIEW_WIDTH).isActive = true
            indexerView.heightAnchor.constraint(equalTo: collectionView.heightAnchor).isActive = true
            indexerView.topAnchor.constraint(equalTo: collectionView.topAnchor).isActive = true
            indexerView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        }
        
        // Indexer center character
        indexerCenterCharacter.translatesAutoresizingMaskIntoConstraints = false
        indexerCenterCharacter.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor).isActive = true
        indexerCenterCharacter.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor).isActive = true
        indexerCenterCharacter.widthAnchor.constraint(equalToConstant: 96).isActive = true
        indexerCenterCharacter.heightAnchor.constraint(equalToConstant: 96).isActive = true
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
    
    func updateTime(currentTime: Double, totalDuration: Double) {
        quickPlayerView.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    func updateMediaInfo(track: AudioTrack) {
        quickPlayerView.updateMediaInfo(track: track)
    }
    
    func updatePlayButtonState(playing: Bool) {
        quickPlayerView.updatePlayButtonState(playing: playing)
    }
    
    func updatePlayOrderButtonState(order: AudioPlayOrder) {
        quickPlayerView.updatePlayOrderButtonState(order: order)
    }
    
    func updateIndexerAlphabet(albumTitles: [String]) {
        collectionIndexerView?.updateAlphabet(strings: albumTitles)
    }
    
    func jumpToItem(index: Int) {
        var index = index / AlbumsView.CELLS_PER_COLUMN
        
        if index >= collectionView.numberOfItems(inSection: 0)
        {
            index = collectionView.numberOfItems(inSection: 0) - 1
        }
        
        let path = IndexPath(item: index, section: 0)
        
        collectionView.scrollToItem(at: path, at: .top, animated: false)
    }
    
    func showIndexerCenterCharacter(character: Character) {
        indexerCenterCharacter.text = String(character)
        
        UIAnimations.stopAnimations(indexerCenterCharacter)
        indexerCenterCharacter.alpha = 1
    }
    
    func hideIndexerCenterCharacter() {
        UIAnimations.animateViewFadeOut(indexerCenterCharacter)
    }
}

// Indexer delegate
extension AlbumsView : CollectionIndexerDelegate {
    func onTouchGestureBegin(selection: CollectionIndexerSelection) {
        // Jump to location
        jumpToItem(index: Int(selection.index))
        
        // Display character
        showIndexerCenterCharacter(character: selection.character)
    }
    
    func onTouchGestureMove(selection: CollectionIndexerSelection) {
        // Jump to location
        jumpToItem(index: Int(selection.index))
        
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

// Custom flow layout
class AlbumsFlowLayout : UICollectionViewFlowLayout
{
    static let CELL_SIZE = CGSize(width: 0, height: 256)
    
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
        
        itemSize = CGSize(width: itemWidth, height: AlbumsFlowLayout.CELL_SIZE.height)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
