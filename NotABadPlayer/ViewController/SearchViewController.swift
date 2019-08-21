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
            self?.presenter?.onSearchQuery(text)
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
            if let currentlyPlaying = AudioPlayer.shared.playlist
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
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylist) {
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
        
        let presenter = PlaylistPresenter(audioInfo: audioInfo, playlist: playlist)
        let vc = PlaylistViewController(presenter: presenter, rootView: self)
        
        presenter.setView(vc)
        self.subViewController = vc
        self.subViewControllerPlaylistName = playlist.name
        
        NavigationHelpers.addVCChild(parent: self, child: vc)
    }
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource?, albumTitles: [String]) {
        
    }
    
    func onPlaylistSongsLoad(name: String, dataSource: PlaylistViewDataSource?, playingTrackIndex: UInt?) {
        
    }
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: ListsViewDataSource?) {
        
    }
    
    func openPlayerScreen(playlist: AudioPlaylist) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(presenter: presenter)
        
        presenter.setView(vc)
        
        NavigationHelpers.presentVC(current: self, vc: vc)
    }
    
    func updatePlayerScreen(playlist: AudioPlaylist) {
        
    }
    
    func updateSearchQueryResults(query: String, dataSource: SearchViewDataSource?, resultsCount: UInt, searchTip: String?) {
        baseView?.collectionDataSource = dataSource
        baseView?.setTextFieldText(query)
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
