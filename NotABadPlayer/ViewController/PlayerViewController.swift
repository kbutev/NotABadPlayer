//
//  PlayerViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController, BaseViewDelegate {
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
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        presenter?.start()
        
        AudioPlayer.shared.attach(observer: self)
        
        Looper.shared.subscribe(self)
    }
    
    private func setup() {
        self.baseView?.onPlayerSeekCallback = {(percentage) in
            let duration = AudioPlayer.shared.durationSec
            
            AudioPlayer.shared.seekTo(seconds: duration * percentage)
        }
        
        self.baseView?.onPlayerButtonClickCallback = {[weak self] (input) in
            self?.presenter?.onPlayerButtonClick(input: input)
        }
        
        self.baseView?.onPlayOrderButtonClickCallback = {[weak self] () in
            self?.presenter?.onPlayOrderButtonClick()
        }
        
        self.baseView?.onSwipeDownCallback = {[weak self] () in
            self?.goBack()
        }
        
        self.baseView?.onSideVolumeBarSeekCallback = {[weak self] (percentage) in
            self?.presenter?.onPlayerVolumeSet(value: percentage)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if any errors have been encountered
        if let error = encounteredError
        {
            self.encounteredError = nil
            
            AlertWindows.shared.show(sourceVC: self, withTitle: "Error", withDescription: error, actionText: "Ok", action: {(action: UIAlertAction) in
                self.goBack()
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Looper.shared.unsubscribe(self)
        
        AudioPlayer.shared.detach(observer: self)
    }
    
    func goBack() {
        NavigationHelpers.dismissPresentedVC(self)
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: BaseAudioPlaylist) {
        
    }
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource?, albumTitles: [String]) {
        
    }
    
    func onPlaylistSongsLoad(name: String, dataSource: PlaylistViewDataSource?, playingTrackIndex: UInt?) {
        
    }
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: ListsViewDataSource?) {
        
    }
    
    func openPlayerScreen(playlist: BaseAudioPlaylist) {
        
    }
    
    func updatePlayerScreen(playlist: BaseAudioPlaylist) {
        self.baseView?.updateUIState(player: AudioPlayer.shared, track: playlist.playingTrack)
    }
    
    func updateSearchQueryResults(query: String, filterIndex: Int, dataSource: SearchViewDataSource?, resultsCount: UInt, searchTip: String?) {
        
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
        
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        self.encounteredError = error.localizedDescription
    }
    
    private func onSystemVolumeChanged(_ value: Double) {
        baseView?.onSystemVolumeChanged(value)
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
        self.baseView?.updateUIState(player: AudioPlayer.shared, track: track)
    }
    
    func onPlayerResume(track: AudioTrack) {
        self.baseView?.updateUIState(player: AudioPlayer.shared, track: track)
    }
    
    func onPlayOrderChange(order: AudioPlayOrder) {
        self.baseView?.updatePlayOrderButtonState(order: order)
    }
    
    func onVolumeChanged(volume: Double) {
        self.onSystemVolumeChanged(volume)
    }
}

extension PlayerViewController : LooperClient {
    func loop() {
        baseView?.updateSoftUIState(player: AudioPlayer.shared)
    }
}
