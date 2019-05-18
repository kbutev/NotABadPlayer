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
    public weak var delegate: PlayerViewDelegate?
    
    private let playlist: AudioPlaylist
    
    required init(playlist: AudioPlaylist) {
        self.playlist = playlist
    }
    
    func start() {
        let player = AudioPlayer.shared
        
        if let currentPlaylist = player.playlist
        {
            // Current playing playlist or track does not match the state of the presenter's playlist?
            if (self.playlist.name != currentPlaylist.name || self.playlist.playingTrack != currentPlaylist.playingTrack)
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
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        
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
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(searchValue: String) {
        
    }
    
    func onAppSettingsReset() {
        
    }
    
    func onAppThemeChange(themeValue: AppTheme) {
        
    }
    
    func onAppSortingChange(albumSorting: AlbumSorting, trackSorting: TrackSorting) {
        
    }
    
    func onAppAppearanceChange(showStars: ShowStars, showVolumeBar: ShowVolumeBar) {
        
    }
    
    func onKeybindChange(action: ApplicationAction, input: ApplicationInput) {
        
    }
    
    private func playFirstTime(playlist: AudioPlaylist) {
        playNew(playlist: playlist)
    }
    
    private func playContinue(playlist: AudioPlaylist) {
        Logging.log(PlayerPresenter.self, "Opening player without changing current audio player state")
        
        delegate?.updatePlayerScreen(playlist: playlist)
    }
    
    private func playNew(playlist: AudioPlaylist) {
        let newPlaylistName = playlist.name
        let newTrack = playlist.playingTrack
        
        Logging.log(PlayerPresenter.self, "Opening player and playing new playlist '\(newPlaylistName)' with track '\(newTrack.title)'")
        
        let player = AudioPlayer.shared
        
        do {
            try player.play(playlist: playlist)
        } catch let error {
            delegate?.onErrorEncountered(message: error.localizedDescription)
            return
        }
        
        if !player.isPlaying
        {
            player.resume()
        }
        
        delegate?.updatePlayerScreen(playlist: playlist)
    }
}
