//
//  PlayerViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController, BaseView {
    private var baseView: PlayerView?
    
    private let presenter: BasePresenter?
    
    private var encounteredError: String?
    
    init(presenter: BasePresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.presenter = nil
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = PlayerView.create(owner: self)
        self.view = self.baseView
        self.baseView?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.start()
        
        AudioPlayer.shared.attach(observer: self)
        
        Looper.shared.subscribe(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if any errors have been encountered
        if let error = encounteredError
        {
            AlertWindows.shared.show(sourceVC: self, withTitle: "Error", withDescription: error, actionText: "Ok", action: {(action: UIAlertAction) in
                self.goBack()
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Looper.shared.unsubscribe(self)
        
        AudioPlayer.shared.detach(observer: self)
    }
    
    func onPlayerSeekChanged(positionInPercentage: Double) {
        let duration = AudioPlayer.shared.durationSec
        
        AudioPlayer.shared.seekTo(seconds: duration * positionInPercentage)
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
        NavigationHelpers.dismissPresentedVC(self)
    }
    
    func onSwipeUp() {
        
    }
    
    func onSwipeDown() {
        self.goBack()
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylist) {
        
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
        
    }
    
    func updatePlayerScreen(playlist: AudioPlaylist) {
        self.baseView?.updateUIState(player: AudioPlayer.shared, track: playlist.playingTrack)
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
        self.encounteredError = error.localizedDescription
    }
}

extension PlayerViewController : AudioPlayerObserver {
    func onPlayerPlay(current: AudioTrack) {
        self.baseView?.updateUIState(player: AudioPlayer.shared, track: current)
    }
    
    func onPlayerFinish() {
        self.baseView?.updatePlayButtonState(player: AudioPlayer.shared)
    }
    
    func onPlayerStop() {
        self.baseView?.updatePlayButtonState(player: AudioPlayer.shared)
    }
    
    func onPlayerPause(track: AudioTrack) {
        self.baseView?.updatePlayButtonState(player: AudioPlayer.shared)
    }
    
    func onPlayerResume(track: AudioTrack) {
        self.baseView?.updatePlayButtonState(player: AudioPlayer.shared)
    }
    
    func onPlayOrderChange(order: AudioPlayOrder) {
        self.baseView?.updatePlayOrderButtonState(order: order)
    }
}

extension PlayerViewController : LooperClient {
    func loop() {
        baseView?.updateSoftUIState(player: AudioPlayer.shared)
    }
}
