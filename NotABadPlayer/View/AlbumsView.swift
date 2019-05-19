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
    
    @IBOutlet var collectionView: UICollectionView!
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
         setup()
    }
    
    private func setup() {
        let guide = self.safeAreaLayoutGuide
        let navigationLayoutHeight = TabController.TAB_SIZE.height
        
        // Quick player view
        quickPlayerView = QuickPlayerView.create(owner: self)
        addSubview(quickPlayerView)
        quickPlayerView.translatesAutoresizingMaskIntoConstraints = false
        quickPlayerView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        quickPlayerView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        quickPlayerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        quickPlayerView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.2).isActive = true
        
        // Collection view
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 2).isActive = true
        collectionView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -2).isActive = true
        collectionView.topAnchor.constraint(equalTo: guide.topAnchor, constant: navigationLayoutHeight).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        let nib = UINib(nibName: String(describing: AlbumsCell.self), bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: AlbumsView.CELL_IDENTIFIER)
        
        flowLayout = AlbumsFlowLayout(cellsPerColumn: AlbumsView.CELLS_PER_COLUMN)
        
        collectionView.collectionViewLayout = flowLayout!
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
