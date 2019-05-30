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
    private weak var delegate: BaseView?
    
    private let audioInfo: AudioInfo
    private let playlist: AudioPlaylist
    
    private var collectionDataSource: PlaylistViewDataSource?
    private var collectionActionDelegate: PlaylistViewActionDelegate?
    
    required init(audioInfo: AudioInfo, playlist: AudioPlaylist) {
        self.audioInfo = audioInfo
        
        // Sort playlist
        // Sort only playlists of type album
        let sorting = GeneralStorage.shared.getTrackSortingValue()
        let sortedPlaylist = playlist.isAlbumPlaylist() ? playlist.sortedPlaylist(withSorting: sorting) : playlist
        self.playlist = sortedPlaylist
    }
    
    func setView(_ view: BaseView) {
        self.delegate = view
    }
    
    func start() {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        let dataSource = PlaylistViewDataSource(audioInfo: audioInfo, playlist: playlist)
        self.collectionDataSource = dataSource
        
        let actionDelegate = PlaylistViewActionDelegate(view: delegate)
        self.collectionActionDelegate = actionDelegate
        
        let audioPlayer = AudioPlayer.shared
        var scrollIndex: UInt? = nil
        
        if let playlist = audioPlayer.playlist
        {
            for e in 0..<playlist.tracks.count
            {
                if playlist.tracks[e] == playlist.playingTrack && self.playlist.name == playlist.name
                {
                    scrollIndex = UInt(e)
                    break
                }
            }
        }
        
        if playlist.isAlbumPlaylist()
        {
            delegate.onAlbumSongsLoad(name: playlist.name, dataSource: dataSource, actionDelegate: actionDelegate)
        }
        else
        {
            delegate.onPlaylistSongsLoad(name: playlist.name, dataSource: dataSource, actionDelegate: actionDelegate)
        }
        
        if let scrollToIndex = scrollIndex
        {
            delegate.scrollTo(index: scrollToIndex)
        }
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
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(PlaylistPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        let _ = Keybinds.shared.performAction(action: action)
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(PlaylistPresenter.self, "Change audio player play order")
        
        let _ = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
    }
    
    func onOpenPlaylistButtonClick() {
        if let playlist = AudioPlayer.shared.playlist
        {
            delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
        }
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(_ query: String) {
        
    }
    
    func onAppSettingsReset() {
        
    }
    
    func onAppThemeChange(themeValue: AppTheme) {
        
    }
    
    func onAppSortingChange(albumSorting: AlbumSorting, trackSorting: TrackSorting) {
        
    }
    
    func onShowVolumeBarSettingChange(_ value: ShowVolumeBar) {
        
    }
    
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay) {
        
    }
    
    func onKeybindChange(action: ApplicationAction, input: ApplicationInput) {
        
    }
    
    private func openPlayerScreen(_ track: AudioTrack) {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        Logging.log(PlaylistPresenter.self, "Opening player screen")
        
        let playlistName = playlist.name
        
        let newPlaylist = AudioPlaylist(name: playlistName, tracks: playlist.tracks, startWithTrack: track)
        
        delegate.openPlayerScreen(playlist: newPlaylist)
    }
    
    private func playNewTrack(_ track: AudioTrack) {
        let player = AudioPlayer.shared
        
        let playlistName = self.playlist.name
        let tracks = self.playlist.tracks
        let playlist = AudioPlaylist(name: playlistName, tracks: tracks, startWithTrack: track)
        
        if let currentPlaylist = player.playlist
        {
            // Current playing playlist or track does not match the state of the presenter's playlist?
            if (playlist.name != currentPlaylist.name || playlist.playingTrack != currentPlaylist.playingTrack)
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
    
    private func playFirstTime(playlist: AudioPlaylist) {
        playNew(playlist: playlist)
    }
    
    private func playNew(playlist: AudioPlaylist) {
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
    }
}
