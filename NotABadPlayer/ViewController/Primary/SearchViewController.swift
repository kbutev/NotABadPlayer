//
//  SearchViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController, BaseView {
    private var baseView: SearchView?
    
    private var presenter: BasePresenter?
    
    private var subViewController: PlaylistViewController?
    
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
        
        presenter?.start()
        
        baseView?.quickPlayerDelegate = self
        baseView?.searchFieldDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        QuickPlayerService.shared.attach(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        QuickPlayerService.shared.detach(observer: self)
    }
    
    func onPlayerSeekChanged(positionInPercentage: Double) {
        
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        presenter?.onPlayerButtonClick(input: input)
    }
    
    func onPlayOrderButtonClick() {
        presenter?.onPlayOrderButtonClick()
    }
    
    func onPlaylistButtonClick() {
        presenter?.onOpenPlaylistButtonClick()
    }
    
    func goBack() {
        self.subViewController?.goBack()
        self.subViewController = nil
    }
    
    func onSwipeUp() {
        if let playlist = AudioPlayer.shared.playlist
        {
            openPlayerScreen(playlist: playlist)
        }
    }
    
    func onSwipeDown() {
        
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylist) {
        
    }
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource, actionDelegate: AlbumsViewActionDelegate, albumTitles: [String]) {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func searchQueryUpdate(dataSource: SearchViewDataSource, actionDelegate: SearchViewActionDelegate, resultsCount: UInt) {
        baseView?.collectionDataSource = dataSource
        baseView?.collectionActionDelegate = actionDelegate
        baseView?.updateSearchResults(resultsCount: resultsCount)
    }
    
    func onSearchResultClick(index: UInt) {
        presenter?.onSearchResultClick(index: index)
    }
    
    func setSearchFieldText(_ text: String) {
        baseView?.setTextFieldText(text)
    }
    
    func onAlbumSongsLoad(name: String,
                          dataSource: PlaylistViewDataSource,
                          actionDelegate: PlaylistViewActionDelegate) {
        
    }
    
    func onPlaylistSongsLoad(name: String,
                             dataSource: PlaylistViewDataSource,
                             actionDelegate: PlaylistViewActionDelegate) {
        
    }
    
    func scrollTo(index: UInt) {
        
    }
    
    func onTrackClicked(index: UInt) {
        
    }
    
    func openPlayerScreen(playlist: AudioPlaylist) {
        let presenter = PlayerPresenter(playlist: playlist)
        let vc = PlayerViewController(presenter: presenter)
        
        presenter.setView(vc)
        
        NavigationHelpers.presentVC(current: self, vc: vc)
    }
    
    func updatePlayerScreen(playlist: AudioPlaylist) {
        
    }
    
    func onOpenPlaylistButtonClick(audioInfo: AudioInfo) {
        if self.subViewController != nil
        {
            fatalError("Logic error in \(String(describing: SearchViewController.self)), cannot open playlist, its already open")
        }
        
        guard let playlist = AudioPlayer.shared.playlist else {
            return
        }
        
        let presenter = PlaylistPresenter(audioInfo: audioInfo, playlist: playlist)
        let vc = PlaylistViewController(presenter: presenter, rootView: self)
        
        presenter.setView(vc)
        
        self.subViewController = vc
        
        NavigationHelpers.addVCChild(parent: self, child: vc)
    }
    
    func onThemeSelect(_ value: AppTheme) {
        
    }
    
    func onTrackSortingSelect(_ value: TrackSorting) {
        
    }
    
    func onShowVolumeBarSelect(_ value: ShowVolumeBar) {
        
    }
    
    func onOpenPlayerOnPlaySelect(_ value: OpenPlayerOnPlay) {
        
    }
    
    func onKeybindSelect(input: ApplicationInput, action: ApplicationAction) {
        
    }
    
    func onResetSettingsDefaults() {
        
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        
    }
}

extension SearchViewController: SearchViewSearchFieldDelegate {
    func onSearchQuery(_ query: String) {
        presenter?.onSearchQuery(query)
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
