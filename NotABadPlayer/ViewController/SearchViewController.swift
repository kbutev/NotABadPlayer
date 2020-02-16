//
//  SearchViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, BaseViewDelegate {
    private var baseView: SearchView?
    
    private var presenter: BasePresenter?
    
    private var subViewController: PlaylistViewController?
    private var subViewControllerPlaylistName: String = ""
    
    private var searchFieldText: String = ""
    private var searchFilterPickedIndex: Int = 0
    
    init(presenter: BasePresenter?) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.presenter = nil
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = SearchView.create(owner: self)
        self.view = self.baseView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        presenter?.start()
    }
    
    private func setup() {
        baseView?.onSearchResultClickedCallback = {[weak self] (index) in
            self?.presenter?.onSearchResultClick(index: index)
        }
        
        baseView?.onSearchFieldTextEnteredCallback = {[weak self] (text) in
            if let strongSelf = self
            {
                strongSelf.searchFieldText = text
                strongSelf.presenter?.onSearchQuery(query: text, filterIndex: strongSelf.searchFilterPickedIndex)
            }
        }
        
        baseView?.onSearchFilterPickedCallback = {[weak self] (index) in
            if let strongSelf = self
            {
                strongSelf.searchFilterPickedIndex = index
                strongSelf.presenter?.onSearchQuery(query: strongSelf.searchFieldText, filterIndex: index)
            }
        }
        
        baseView?.onQuickPlayerPlaylistButtonClickCallback = { [weak self] () in
            self?.presenter?.onOpenPlaylistButtonClick()
        }
        
        baseView?.onQuickPlayerButtonClickCallback = { [weak self] (input) in
            self?.presenter?.onPlayerButtonClick(input: input)
        }
        
        baseView?.onQuickPlayerPlayOrderButtonClickCallback = { [weak self] () in
            self?.presenter?.onPlayOrderButtonClick()
        }
        
        baseView?.onQuickPlayerSwipeUpCallback = { [weak self] () in
            if let currentlyPlaying = AudioPlayerService.shared.playlist
            {
                self?.presenter?.onOpenPlayer(playlist: currentlyPlaying)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        QuickPlayerService.shared.attach(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        QuickPlayerService.shared.detach(observer: self)
    }
    
    func goBack() {
        self.subViewController?.goBack()
        self.subViewController = nil
        self.subViewControllerPlaylistName = ""
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: BaseAudioPlaylist, options: OpenPlaylistOptions) {
        if self.subViewController != nil
        {
            // Correct playlist is already open? Do nothing
            if playlist.name == self.subViewControllerPlaylistName
            {
                Logging.log(SearchViewController.self, "No need to open playlist screen, its already open for the correct playlist")
                return
            }
            
            Logging.log(SearchViewController.self, "Close current playlist screen, and reopen it for the correct playlist")
            goBack()
        }
        
        let presenter = PlaylistPresenter(audioInfo: audioInfo, playlist: playlist, options: options)
        let vc = PlaylistViewController(presenter: presenter, rootView: self)
        
        presenter.setView(vc)
        self.subViewController = vc
        self.subViewControllerPlaylistName = playlist.name
        
        NavigationHelpers.addVCChild(parent: self, child: vc)
    }
    
    func onMediaAlbumsLoad(dataSource: BaseAlbumsViewDataSource?, albumTitles: [String]) {
        
    }
    
    func onPlaylistSongsLoad(name: String, dataSource: BasePlaylistViewDataSource?, playingTrackIndex: UInt?) {
        
    }
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: BaseListsViewDataSource?) {
        
    }
    
    func openPlayerScreen(playlist: BaseAudioPlaylist) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(presenter: presenter)
        
        presenter.setView(vc)
        
        NavigationHelpers.presentVC(current: self, vc: vc)
    }
    
    func updatePlayerScreen(playlist: BaseAudioPlaylist) {
        
    }
    
    func updateSearchQueryResults(query: String, filterIndex: Int, dataSource: BaseSearchViewDataSource?, resultsCount: UInt, searchTip: String?) {
        searchFieldText = query
        searchFilterPickedIndex = filterIndex
        
        baseView?.collectionDataSource = dataSource
        baseView?.favoritesChecker = self
        baseView?.setTextFieldText(query)
        baseView?.setTextFilterIndex(filterIndex)
        baseView?.updateSearchResults(resultsCount: resultsCount, searchTip: searchTip)
    }
    
    func onResetSettingsDefaults() {
        
    }
    
    func onThemeSelect(_ value: AppThemeValue) {
        
    }
    
    func onTrackSortingSelect(_ value: TrackSorting) {
        
    }
    
    func onShowVolumeBarSelect(_ value: ShowVolumeBar) {
        
    }
    
    func onAudioLibraryChanged() {
        
    }
    
    func onFetchDataErrorEncountered(_ error: Error) {
        // Fetch data again until successful
        presenter?.fetchData()
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: "Error",
                                 withDescription: error.localizedDescription,
                                 actionText: "Ok",
                                 action: nil)
    }
}

extension SearchViewController : QuickPlayerObserver {
    func updateTime(currentTime: Double, totalDuration: Double) {
        baseView?.updateTime(currentTime: currentTime, totalDuration: totalDuration)
    }
    
    func updateMediaInfo(track: AudioTrack) {
        baseView?.updateMediaInfo(track: track)
    }
    
    func updatePlayButtonState(isPlaying: Bool) {
        baseView?.updatePlayButtonState(playing: isPlaying)
    }
    
    func updatePlayOrderButtonState(order: AudioPlayOrder) {
        baseView?.updatePlayOrderButtonState(order: order)
    }
}

extension SearchViewController : BaseSearchFavoritesChecker {
    func isMarkedFavorite(item: AudioTrack) -> Bool {
        return GeneralStorage.shared.favorites.isMarkedFavorite(item)
    }
}
