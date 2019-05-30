//
//  AlbumsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController, BaseView {
    private var baseView: PlaylistView?
    
    private let presenter: BasePresenter?
    private let rootView: BaseView?
    
    init(presenter: BasePresenter, rootView: BaseView) {
        self.presenter = presenter
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.presenter = nil
        self.rootView = nil
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = PlaylistView.create(owner: self)
        self.view = self.baseView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.start()
        
        self.baseView?.quickPlayerDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        baseView?.reloadData()
        
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
        NavigationHelpers.removeVCChild(self)
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
        // Forward request to delegate
        rootView?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
    }
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource, actionDelegate: AlbumsViewActionDelegate, albumTitles: [String]) {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func searchQueryUpdate(dataSource: SearchViewDataSource, actionDelegate: SearchViewActionDelegate, resultsCount: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func setSearchFieldText(_ text: String) {
        
    }
    
    func onAlbumSongsLoad(name: String,
                          dataSource: PlaylistViewDataSource,
                          actionDelegate: PlaylistViewActionDelegate) {
        self.baseView?.collectionDataSource = dataSource
        self.baseView?.collectionActionDelegate = actionDelegate
        self.baseView?.updateOverlayTitle(title: name)
        self.baseView?.reloadData()
    }
    
    func onPlaylistSongsLoad(name: String,
                             dataSource: PlaylistViewDataSource,
                             actionDelegate: PlaylistViewActionDelegate) {
        self.baseView?.collectionDataSource = dataSource
        self.baseView?.collectionActionDelegate = actionDelegate
        self.baseView?.updateOverlayTitle(title: name)
        self.baseView?.reloadData()
    }
    
    func scrollTo(index: UInt) {
        self.baseView?.scrollDownToSelectedTrack(index: index)
    }
    
    func onTrackClicked(index: UInt) {
        self.presenter?.onPlaylistItemClick(index: index)
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
           AlertWindows.shared.show(sourceVC: self, withTitle: "Error", withDescription: error.localizedDescription, actionText: "Ok", action: nil)
    }
}

extension PlaylistViewController : QuickPlayerObserver {
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
