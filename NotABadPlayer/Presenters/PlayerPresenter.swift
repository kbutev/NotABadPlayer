//
//  PlayerPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class PlayerPresenter: BasePresenter
{
    private weak var delegate: BaseViewDelegate?
    
    private let playlist: BaseAudioPlaylist
    
    required init(playlist: BaseAudioPlaylist) {
        self.playlist = playlist
    }
    
    func setView(_ delegate: BaseViewDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        let player = AudioPlayer.shared
        
        if let currentPlaylist = player.playlist
        {
            // Current playing playlist or track does not match the state of the presenter's playlist?
            if (!(self.playlist.equals(currentPlaylist)))
            {
                // Change the audio player playlist to equal the presenter's playlist
                playNew(playlist: self.playlist)
                
                return
            }
            
            // Just open screen
            playContinue(playlist: currentPlaylist)
            
            return
        }
        
        // Set audio player playlist for the first time and play its track
        playFirstTime(playlist: self.playlist)
    }
    
    func fetchData() {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        
    }
    
    func onOpenPlayer(playlist: BaseAudioPlaylist) {
        
    }
    
    func contextAudioTrackLyrics() -> String? {
        return self.playlist.playingTrack.lyrics
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(PlayerPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        let _ = Keybinds.shared.performAction(action: action)
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(PlayerPresenter.self, "Change play order")
        
        let _ = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
    }
    
    func onOpenPlaylistButtonClick() {
        
    }
    
    func onPlayerVolumeSet(value: Double) {
        AudioPlayer.shared.volume = Int(value)
    }
    
    func onPlaylistItemDelete(index: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(query: String, filterIndex: Int) {
        
    }
    
    func onAppSettingsReset() {
        
    }
    
    func onAppThemeChange(_ themeValue: AppThemeValue) {
        
    }
    
    func onTrackSortingSettingChange(_ trackSorting: TrackSorting) {
        
    }
    
    func onShowVolumeBarSettingChange(_ value: ShowVolumeBar) {
        
    }
    
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay) {
        
    }
    
    func onKeybindChange(input: ApplicationInput, action: ApplicationAction) {
        
    }
    
    private func playContinue(playlist: BaseAudioPlaylist) {
        Logging.log(PlayerPresenter.self, "Opening player without changing current audio player state")
        
        delegate?.updatePlayerScreen(playlist: playlist)
    }
    
    private func playFirstTime(playlist: BaseAudioPlaylist) {
        playNew(playlist: playlist)
    }
    
    private func playNew(playlist: BaseAudioPlaylist) {
        let newPlaylistName = playlist.name
        let newTrack = playlist.playingTrack
        
        Logging.log(PlayerPresenter.self, "Opening player and playing new playlist '\(newPlaylistName)' with track '\(newTrack.title)'")
        
        let player = AudioPlayer.shared
        
        do {
            try player.play(playlist: playlist)
        } catch let error {
            delegate?.onPlayerErrorEncountered(error)
            return
        }
        
        if !player.isPlaying
        {
            player.resume()
        }
        
        delegate?.updatePlayerScreen(playlist: playlist)
    }
}
