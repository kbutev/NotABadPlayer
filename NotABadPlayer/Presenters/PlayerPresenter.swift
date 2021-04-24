//
//  PlayerPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol PlayerPresenterProtocol: BasePresenter {
    var delegate: PlayerViewControllerProtocol? { get set }
    
    var contextAudioTrackLyrics: String? { get }
    
    func onPlayerButtonClick(input: ApplicationInput)
    func onPlayOrderButtonClick()
    func onPlayerVolumeSet(value: Double)
    
    func onMarkOrUnmarkContextTrackFavorite() -> Bool
}

class PlayerPresenter: PlayerPresenterProtocol {
    weak var delegate: PlayerViewControllerProtocol?
    
    private let playlist: AudioPlaylistProtocol
    
    required init(playlist: AudioPlaylistProtocol) {
        self.playlist = playlist
    }
    
    // PlayerPresenterProtocol
    
    func start() {
        let player = AudioPlayerService.shared
        
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
    
    var contextAudioTrackLyrics: String? {
        return AudioPlayerService.shared.playingTrack?.lyrics
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
    
    func onPlayerVolumeSet(value: Double) {
        AudioPlayerService.shared.volume = Int(value)
    }
    
    func onMarkOrUnmarkContextTrackFavorite() -> Bool {
        guard let track = AudioPlayerService.shared.playingTrack else
        {
            return false
        }
        
        let isFavorite = GeneralStorage.shared.favorites.isMarkedFavorite(track)
        
        if isFavorite {
            GeneralStorage.shared.favorites.unmarkFavorite(track: track)
        } else {
            GeneralStorage.shared.favorites.markFavoriteForced(track: track)
        }
        
        return !isFavorite
    }
    
    private func playContinue(playlist: AudioPlaylistProtocol) {
        Logging.log(PlayerPresenter.self, "Opening player without changing current audio player state")
        
        delegate?.updatePlayerScreen(playlist: playlist)
    }
    
    private func playFirstTime(playlist: AudioPlaylistProtocol) {
        playNew(playlist: playlist)
    }
    
    private func playNew(playlist: AudioPlaylistProtocol) {
        let newPlaylistName = playlist.name
        let newTrack = playlist.playingTrack
        
        Logging.log(PlayerPresenter.self, "Opening player and playing new playlist '\(newPlaylistName)' with track '\(newTrack.title)'")
        
        let player = AudioPlayerService.shared
        
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
