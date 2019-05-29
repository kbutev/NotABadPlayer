//
//  SearchView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 29.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class SearchViewDataSource : NSObject, UICollectionViewDataSource
{
    let audioInfo: AudioInfo
    let searchResults: [AudioTrack]
    
    init(audioInfo: AudioInfo, searchResults: [AudioTrack]) {
        self.audioInfo = audioInfo
        self.searchResults = searchResults
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchView.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? SearchItemCell else {
            return reusableCell
        }
        
        let item = searchResults[indexPath.row]
        
        cell.trackAlbumCover.image = item.albumCover?.image(at: cell.trackAlbumCover!.frame.size)
        cell.titleText.text = item.title
        cell.albumTitle.text = item.albumTitle
        cell.durationText.text = item.duration
        
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
}

class SearchViewActionDelegate : NSObject, UICollectionViewDelegate
{
    private weak var view: SearchViewDelegate?
    
    init(view: SearchViewDelegate) {
        self.view = view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view?.onSearchResultClick(index: UInt(indexPath.row))
    }
}

protocol SearchViewSearchFieldDelegate: class {
    func onSearchQuery(_ query: String)
}

class SearchView: UIView
{
    static let CELL_IDENTIFIER = "cell"
    static let TOP_MARGIN: CGFloat = 8
    static let HORIZONTAL_MARGIN: CGFloat = 8
    
    private var initialized: Bool = false
    
    private var flowLayout: SearchFlowLayout?
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var searchField: UITextField!
    @IBOutlet var searchDescription: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var quickPlayerView: QuickPlayerView!
    
    var searchFieldDelegate : SearchViewSearchFieldDelegate?
    
    var collectionDataSource : SearchViewDataSource? {
        get {
            return collectionView.dataSource as? SearchViewDataSource
        }
        set {
            collectionView.dataSource = newValue
        }
    }
    
    var collectionActionDelegate : SearchViewActionDelegate? {
        get {
            return collectionView.delegate as? SearchViewActionDelegate
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
    
    override func awakeFromNib() {
        searchDescription.text = Text.value(.Empty)
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
        
        // Stack view
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: SearchView.HORIZONTAL_MARGIN).isActive = true
        stackView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -SearchView.HORIZONTAL_MARGIN).isActive = true
        stackView.topAnchor.constraint(equalTo: guide.topAnchor, constant: SearchView.TOP_MARGIN).isActive = true
        stackView.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        // Collection
        let cellNib = UINib(nibName: String(describing: SearchItemCell.self), bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: SearchView.CELL_IDENTIFIER)
        
        flowLayout = SearchFlowLayout()
        
        collectionView.collectionViewLayout = flowLayout!
        
        // Search field interaction
        searchField.delegate = self
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
    
    public func setTextFieldText(_ text: String) {
        searchField.text = text
    }
    
    public func updateSearchResults(resultsCount: UInt) {
        if resultsCount == 0
        {
            let isEmpty = searchField.text?.isEmpty ?? true
            
            if isEmpty
            {
                searchDescription.text = Text.value(.Empty)
            }
            else
            {
                searchDescription.text = Text.value(.SearchDescriptionNoResults)
            }
        }
        else
        {
            searchDescription.text = Text.value(.SearchDescriptionResults, "\(resultsCount)")
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
}

// Text field actions
extension SearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let query = textField.text
        {
            searchFieldDelegate?.onSearchQuery(query)
        }
        
        return true
    }
}

// Builder
extension SearchView {
    class func create(owner: Any) -> SearchView? {
        let bundle = Bundle.main
        let nibName = String(describing: SearchView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? SearchView
    }
}

// Custom flow layout
class SearchFlowLayout : UICollectionViewFlowLayout
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
        
        itemSize = CGSize(width: itemWidth, height: SearchFlowLayout.CELL_SIZE.height)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}

