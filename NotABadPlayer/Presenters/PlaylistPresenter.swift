//
//  PlaylistPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class PlaylistPresenter: BasePresenter
{
    private weak var delegate: BaseViewDelegate?
    
    private let audioInfo: AudioInfo
    private let playlist: BaseAudioPlaylist
    
    private var collectionDataSource: PlaylistViewDataSource?
    
    required init(audioInfo: AudioInfo, playlist: BaseAudioPlaylist) {
        self.audioInfo = audioInfo
        
        // Sort playlist
        // Sort only playlists of type album
        let sorting = GeneralStorage.shared.getTrackSortingValue()
        let sortedPlaylist = playlist.isAlbumPlaylist() ? playlist.sortedPlaylist(withSorting: sorting) : playlist
        self.playlist = sortedPlaylist
    }
    
    func setView(_ delegate: BaseViewDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        let dataSource = PlaylistViewDataSource(audioInfo: audioInfo, playlist: playlist)
        self.collectionDataSource = dataSource
        
        let audioPlayer = AudioPlayer.shared
        var scrollIndex: UInt? = nil
        
        if let playlist = audioPlayer.playlist
        {
            if self.playlist.name == playlist.name
            {
                for e in 0..<playlist.tracks.count
                {
                    if playlist.tracks[e] == playlist.playingTrack
                    {
                        scrollIndex = UInt(e)
                        break
                    }
                }
            }
        }
        
        delegate.onPlaylistSongsLoad(name: playlist.name, dataSource: dataSource, playingTrackIndex: scrollIndex)
    }
    
    func fetchData() {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        if index >= playlist.tracks.count
        {
            return
        }
        
        let clickedTrack = playlist.tracks[Int(index)]
        
        if GeneralStorage.shared.getOpenPlayerOnPlayValue().openForPlaylist()
        {
            openPlayerScreen(clickedTrack)
        }
        else
        {
            playNewTrack(clickedTrack)
        }
    }
    
    func onOpenPlayer(playlist: BaseAudioPlaylist) {
        Logging.log(PlaylistPresenter.self, "Open player screen")
        
        self.delegate?.openPlayerScreen(playlist: playlist)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(PlaylistPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        if let error = Keybinds.shared.performAction(action: action)
        {
            delegate?.onPlayerErrorEncountered(error)
        }
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(PlaylistPresenter.self, "Change audio player play order")
        
        if let error = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
        {
            delegate?.onPlayerErrorEncountered(error)
        }
    }
    
    func onOpenPlaylistButtonClick() {
        if let playlist = AudioPlayer.shared.playlist
        {
            delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
        }
    }
    
    func onPlayerVolumeSet(value: Double) {
        
    }
    
    func onPlaylistItemDelete(index: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(_ query: String) {
        
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
    
    private func openPlayerScreen(_ track: AudioTrack) {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        Logging.log(PlaylistPresenter.self, "Opening player screen")
        
        let playlistName = playlist.name
        
        do {
            var node = AudioPlaylistBuilder.start()
            node.name = playlistName
            node.tracks = playlist.tracks
            node.playingTrack = track
            
            let newPlaylist = try node.build()
            delegate.openPlayerScreen(playlist: newPlaylist)
        } catch let e {
            Logging.log(PlaylistPresenter.self, "Error: cannot open player screen: \(e.localizedDescription)")
        }
    }
    
    private func playNewTrack(_ track: AudioTrack) {
        let player = AudioPlayer.shared
        
        let playlistName = self.playlist.name
        let tracks = self.playlist.tracks
        
        var playlist: BaseAudioPlaylist!
        
        do {
            var node = AudioPlaylistBuilder.start()
            node.name = playlistName
            node.tracks = tracks
            node.playingTrack = track
            
            playlist = try node.build()
        } catch let e {
            Logging.log(PlaylistPresenter.self, "Error: cannot play track: \(e.localizedDescription)")
            return
        }
        
        if let currentPlaylist = player.playlist
        {
            // Current playing playlist or track does not match the state of the presenter's playlist?
            if (!(playlist.equals(currentPlaylist)))
            {
                // Change the audio player playlist to equal the presenter's playlist
                Logging.log(PlaylistPresenter.self, "Playing track '\(playlist.playingTrack.title)' from playlist '\(playlist.name)'")
                playNew(playlist: playlist)
                
                return
            }
            
            // Do nothing, track is already playing
            
            return
        }
        
        // Set audio player playlist for the first time and play its track
        Logging.log(PlaylistPresenter.self, "Playing track '\(playlist.playingTrack.title)' from playlist '\(playlist.name)' for the first time")
        playFirstTime(playlist: playlist)
    }
    
    private func playFirstTime(playlist: BaseAudioPlaylist) {
        playNew(playlist: playlist)
    }
    
    private func playNew(playlist: BaseAudioPlaylist) {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        let player = AudioPlayer.shared
        
        do {
            try player.play(playlist: playlist)
        } catch let e {
            delegate.onPlayerErrorEncountered(e)
        }
        
        if !player.isPlaying
        {
            player.resume()
        }
        
        delegate.updatePlayerScreen(playlist: playlist)
    }
}
