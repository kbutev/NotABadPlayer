//
//  SearchView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 29.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class SearchView: UIView
{
    public static let SHINY_STAR_IMAGE = "shiny_star"
    public static let FAVORITES_ICON_SIZE = CGRect(x: 0, y: 1, width: 12, height: 12)
    public static let TOP_MARGIN: CGFloat = 8
    public static let HORIZONTAL_MARGIN: CGFloat = 8
    
    private var initialized: Bool = false
    
    private var flowLayout: SearchFlowLayout?
    
    public var collectionActionDelegate : BaseSearchViewActionDelegate?
    
    public var collectionDataSource : BaseSearchViewDataSource? {
        get {
            return collectionView.dataSource as? BaseSearchViewDataSource
        }
        set {
            newValue?.favoritesChecker = self.favoritesChecker
            collectionView.dataSource = newValue
        }
    }
    
    public weak var favoritesChecker : BaseSearchFavoritesChecker? {
        get {
            return (collectionView.dataSource as? BaseSearchViewDataSource)?.favoritesChecker
        }
        set {
            (collectionView.dataSource as? BaseSearchViewDataSource)?.favoritesChecker = newValue
        }
    }
    
    public var onSearchResultClickedCallback: (UInt)->Void = {(index) in }
    public var onSearchFieldTextEnteredCallback: (String)->Void = {(text) in }
    public var onSearchFilterPickedCallback: (Int)->Void = {(index) in }
    
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
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var searchFilterPicker: UISegmentedControl!
    @IBOutlet weak var searchDescription: UILabel!
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
        self.collectionActionDelegate = SearchViewActionDelegate(view: self)
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
        else if self.superview == nil
        {
            searchFilterPicker.removeTarget(self, action: #selector(pickerValueChanged), for: .valueChanged)
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
        
        // Stack setup
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: SearchView.HORIZONTAL_MARGIN).isActive = true
        stackView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -SearchView.HORIZONTAL_MARGIN).isActive = true
        stackView.topAnchor.constraint(equalTo: guide.topAnchor, constant: SearchView.TOP_MARGIN).isActive = true
        stackView.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
        
        // Collection setup
        let cellNib = UINib(nibName: String(describing: SearchItemCell.self), bundle: nil)
        collectionView.register(cellNib, forCellWithReuseIdentifier: SearchItemCell.CELL_IDENTIFIER)
        
        flowLayout = SearchFlowLayout()
        
        collectionView.collectionViewLayout = flowLayout!
        
        collectionView.delegate = self.collectionActionDelegate
        
        // Search field interaction setup
        searchField.delegate = self
        
        // Search filter picker setup
        searchFilterPicker.addTarget(self, action: #selector(pickerValueChanged), for: .valueChanged)
    }
    
    public func setupAppTheme() {
        self.backgroundColor = AppTheme.shared.colorFor(.STANDART_BACKGROUND)
        
        collectionView.backgroundColor = .clear
        searchDescription.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        
        let segmentedTextColor = [NSAttributedString.Key.foregroundColor: AppTheme.shared.colorFor(.SEARCH_FILTER_PICKER_TINT)]
        let segmentedSelTextColor = [NSAttributedString.Key.foregroundColor: AppTheme.shared.colorFor(.SEARCH_FILTER_PICKER_SELECTION)]
        let segmentedTintColor = AppTheme.shared.colorFor(.SEARCH_FILTER_PICKER_TINT)
        searchFilterPicker.setTitleTextAttributes(segmentedTextColor, for: .normal)
        searchFilterPicker.setTitleTextAttributes(segmentedSelTextColor, for: .selected)
        searchFilterPicker.tintColor = segmentedTintColor
        
        collectionView.indicatorStyle = AppTheme.shared.scrollBarColor()
    }
    
    public func reloadData() {
        collectionView.reloadData()
    }
    
    public func setTextFieldText(_ text: String) {
        searchField.text = text
    }
    
    public func setTextFilterIndex(_ index: Int) {
        searchFilterPicker.selectedSegmentIndex = index
    }
    
    public func updateSearchResults(resultsCount: UInt, searchTip: String?) {
        if let tip = searchTip
        {
            searchDescription.text = tip
            return
        }
        
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
    
    public func updateTime(currentTime: Double, totalDuration: Double) {
        quickPlayerView.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    public func updateMediaInfo(track: BaseAudioTrack) {
        quickPlayerView.updateMediaInfo(track: track)
        
        reloadData()
    }
    
    public func updatePlayButtonState(playing: Bool) {
        quickPlayerView.updatePlayButtonState(playing: playing)
    }
    
    public func updatePlayOrderButtonState(order: AudioPlayOrder) {
        quickPlayerView.updatePlayOrderButtonState(order: order)
    }
    
    public func playSelectionAnimation(reloadData: Bool) {
        collectionDataSource?.playSelectionAnimation()
        
        if reloadData
        {
            self.reloadData()
        }
    }
}

// Actions
extension SearchView {
    @objc func actionSearchResultClick(index: UInt) {
        self.onSearchResultClickedCallback(index)
    }
}

// Text field actions
extension SearchView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if let query = textField.text
        {
            self.onSearchFieldTextEnteredCallback(query)
        }
        
        return true
    }
}

// Picker actions
extension SearchView {
    @objc func pickerValueChanged(_ sender: Any) {
        let index = self.searchFilterPicker.selectedSegmentIndex
        
        self.onSearchFilterPickedCallback(index)
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

// Collection data source
class SearchViewDataSource : NSObject, BaseSearchViewDataSource
{
    public weak var favoritesChecker : BaseSearchFavoritesChecker?
    
    let audioInfo: AudioInfo
    let searchResults: [BaseAudioTrack]
    
    private var playSelectionAnimationNextTime: Bool = false
    
    init(audioInfo: AudioInfo, searchResults: [BaseAudioTrack]) {
        self.audioInfo = audioInfo
        self.searchResults = searchResults
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let reusableCell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchItemCell.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? SearchItemCell else {
            return reusableCell
        }
        
        let item = searchResults[indexPath.row]
        let isFavorite = favoritesChecker?.isMarkedFavorite(item: item) ?? false
        
        cell.trackAlbumCover.image = item.albumCoverImage
        cell.titleText.text = item.title
        cell.albumTitle.text = item.albumTitle
        cell.durationText.attributedText = buildAttributedDescription(duration: item.duration, isFavorite: isFavorite)
        
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
    
    public func playSelectionAnimation() {
        self.playSelectionAnimationNextTime = true
    }
    
    func buildAttributedDescription(duration: String, isFavorite: Bool=false) -> NSAttributedString {
        if !isFavorite {
            return NSMutableAttributedString(string: duration)
        }
        
        let fullString = NSMutableAttributedString()
        
        let imageAttachment = NSTextAttachment()
        imageAttachment.image = UIImage(named: PlaylistView.SHINY_STAR_IMAGE)
        imageAttachment.bounds = PlaylistView.FAVORITES_ICON_SIZE
        
        let imageString = NSAttributedString(attachment: imageAttachment)
        fullString.append(imageString)
        fullString.append(NSAttributedString(string: " " + duration))
        
        return fullString
    }
}

// Collection delegate
class SearchViewActionDelegate : NSObject, BaseSearchViewActionDelegate
{
    private weak var view: SearchView?
    
    init(view: SearchView) {
        self.view = view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.view?.playSelectionAnimation(reloadData: false)
        self.view?.actionSearchResultClick(index: UInt(indexPath.row))
    }
}

// Collection flow layout
class SearchFlowLayout : UICollectionViewFlowLayout
{
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
        
        itemSize = CGSize(width: itemWidth, height: SearchItemCell.SIZE.height)
    }
    
    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds) as! UICollectionViewFlowLayoutInvalidationContext
        context.invalidateFlowLayoutDelegateMetrics = newBounds.size != collectionView?.bounds.size
        return context
    }
}
