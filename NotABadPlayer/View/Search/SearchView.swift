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
    public var collectionActionDelegate : SearchViewActionDelegate?
    
    public var collectionDataSource : SearchViewDataSource? {
        get { return searchBaseView.collectionDataSource }
        set { searchBaseView.collectionDataSource = newValue }
    }
    
    public var highlightedChecker : SearchHighlighedChecker? {
        get { return searchBaseView.highlightedChecker }
        set { searchBaseView.highlightedChecker = newValue }
    }
    
    public var favoritesChecker : SearchFavoritesChecker? {
        get { return searchBaseView.favoritesChecker }
        set { searchBaseView.favoritesChecker = newValue }
    }
    
    public var onSearchResultClickedCallback: (UInt)->Void {
        get { return searchBaseView.onSearchResultClickedCallback }
        set { searchBaseView.onSearchResultClickedCallback = newValue }
    }
    public var onSearchFieldTextEnteredCallback: (String)->Void {
        get { return searchBaseView.onSearchFieldTextEnteredCallback }
        set { searchBaseView.onSearchFieldTextEnteredCallback = newValue }
    }
    public var onSearchFilterPickedCallback: (Int)->Void {
        get { return searchBaseView.onSearchFilterPickedCallback }
        set { searchBaseView.onSearchFilterPickedCallback = newValue }
    }
    
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
    
    var searchBaseView: SearchViewPlain!
    
    var quickPlayerView: QuickPlayerView!
    
    private var initialized: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        self.quickPlayerView = QuickPlayerView.createAndAttach(to: self)
        self.searchBaseView = SearchViewPlain.create(owner: self)
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
        
        addSubview(searchBaseView)
        addSubview(quickPlayerView)
        
        // Search plain view setup
        searchBaseView.translatesAutoresizingMaskIntoConstraints = false
        searchBaseView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        searchBaseView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: 0).isActive = true
        searchBaseView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: 0).isActive = true
        searchBaseView.bottomAnchor.constraint(equalTo: quickPlayerView.topAnchor).isActive = true
    }
    
    public func reloadData() {
        searchBaseView.reloadData()
    }
    
    public func showLoadingIndicator() {
        searchBaseView.showLoadingIndicator()
    }
    
    public func hideLoadingIndicator() {
        searchBaseView.hideLoadingIndicator()
    }
    
    public func setTextFieldText(_ text: String) {
        searchBaseView.setTextFieldText(text)
    }
    
    public func setTextFilterIndex(_ index: Int) {
        searchBaseView.setTextFilterIndex(index)
    }
    
    public func updateSearchDescriptionToLoading() {
        searchBaseView.updateSearchDescriptionToLoading()
    }
    
    public func updateSearchDescription(resultsCount: UInt) {
        searchBaseView.updateSearchDescription(resultsCount: resultsCount)
    }
    
    public func playSelectionAnimation(reloadData: Bool) {
        searchBaseView.playSelectionAnimation(reloadData: reloadData)
    }
}

// QuickPlayerObserver
extension SearchView: QuickPlayerObserver {
    public func updateTime(currentTime: Double, totalDuration: Double) {
        quickPlayerView.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    public func updateMediaInfo(track: AudioTrackProtocol) {
        quickPlayerView.updateMediaInfo(track: track)
        
        self.searchBaseView.reloadData()
    }
    
    public func updatePlayButtonState(isPlaying: Bool) {
        quickPlayerView.updatePlayButtonState(isPlaying: isPlaying)
    }
    
    public func updatePlayOrderButtonState(order: AudioPlayOrder) {
        quickPlayerView.updatePlayOrderButtonState(order: order)
    }
    
    func onVolumeChanged(volume: Double) {
        
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
