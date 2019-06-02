//
//  ListsPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class ListsPresenter: BasePresenter
{
    private weak var delegate: BaseViewDelegate?
    
    private let audioInfo: AudioInfo
    
    private var playlists: [AudioPlaylist] = []
    
    private var collectionDataSource: ListsViewDataSource?
    
    required init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
    }
    
    func setView(_ delegate: BaseViewDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        self.playlists = GeneralStorage.shared.getUserPlaylists()
        let recentlyPlayed = AudioPlayer.shared.playHistory
        let recentlyPlayedPlaylist = recentlyPlayed.count > 0 ? AudioPlaylist(name: Text.value(.PlaylistRecentlyPlayed), tracks: recentlyPlayed) : nil
        
        if recentlyPlayedPlaylist != nil
        {
            playlists.append(recentlyPlayedPlaylist!)
        }
        
        self.collectionDataSource = ListsViewDataSource(audioInfo: audioInfo, playlists: playlists)
        
        delegate?.onUserPlaylistsLoad(dataSource: collectionDataSource)
    }
    
    func onAppStateChange(state: AppState) {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        
        if index >= self.playlists.count
        {
            return
        }
        
        let playlist = self.playlists[Int(index)]
        
        Logging.log(ListsPresenter.self, "Open playlist screen for playlist \(playlist.name)")
        
        self.delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
    }
    
    func onOpenPlayer(playlist: AudioPlaylist) {
        Logging.log(ListsPresenter.self, "Open player screen")
        
        self.delegate?.openPlayerScreen(playlist: playlist)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(ListsPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        let _ = Keybinds.shared.performAction(action: action)
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(ListsPresenter.self, "Change audio player play order")
        
        let _ = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
    }
    
    func onOpenPlaylistButtonClick() {
        if let playlist = AudioPlayer.shared.playlist
        {
            delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
        }
    }
    
    func onPlaylistItemDelete(index: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(_ query: String) {
        
    }
    
    func onAppSettingsReset() {
        
    }
    
    func onAppThemeChange(_ themeValue: AppTheme) {
        
    }
    
    func onTrackSortingSettingChange(_ trackSorting: TrackSorting) {
        
    }
    
    func onShowVolumeBarSettingChange(_ value: ShowVolumeBar) {
        
    }
    
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay) {
        
    }
    
    func onKeybindChange(input: ApplicationInput, action: ApplicationAction) {
        
    }
}
