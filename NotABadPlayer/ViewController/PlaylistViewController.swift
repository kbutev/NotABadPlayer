//
//  AlbumsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class PlaylistViewController: UIViewController, BaseViewDelegate {
    private var baseView: PlaylistView?
    
    private let presenter: BasePresenter?
    private let rootView: BaseViewDelegate?
    
    init(presenter: BasePresenter, rootView: BaseViewDelegate) {
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
        
        setup()
        
        presenter?.start()
    }
    
    private func setup() {
        baseView?.onTrackClickedCallback = {[weak self] (index) in
            self?.presenter?.onPlaylistItemClick(index: index)
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
        baseView?.reloadData()
        
        QuickPlayerService.shared.attach(observer: self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        QuickPlayerService.shared.detach(observer: self)
    }
    
    func goBack() {
        // This is called by the parent when we call their goBack()
        NavigationHelpers.removeVCChild(self)
    }
    
    func goBackReal() {
        // Call this to tell the parent to go back, which will cause this instance's goBack() to be called
        rootView?.goBack()
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylist) {
        // Forward request to delegate
        rootView?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
    }
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource?, albumTitles: [String]) {
        
    }
    
    func onPlaylistSongsLoad(name: String, dataSource: PlaylistViewDataSource?, playingTrackIndex: UInt?) {
        self.baseView?.collectionDataSource = dataSource
        self.baseView?.updateOverlayTitle(title: name)
        
        if let scrollToIndex = playingTrackIndex
        {
            self.baseView?.scrollDownToSelectedTrack(index: scrollToIndex)
        }
        
        self.baseView?.reloadData()
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
    
    func searchQueryResults(query: String, dataSource: SearchViewDataSource?, resultsCount: UInt, searchTip: String?) {
        
    }
    
    func onResetSettingsDefaults() {
        
    }
    
    func onThemeSelect(_ value: AppTheme) {
        
    }
    
    func onTrackSortingSelect(_ value: TrackSorting) {
        
    }
    
    func onShowVolumeBarSelect(_ value: ShowVolumeBar) {
        
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: "Error",
                                 withDescription: error.localizedDescription,
                                 actionText: "Ok",
                                 action: nil)
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
