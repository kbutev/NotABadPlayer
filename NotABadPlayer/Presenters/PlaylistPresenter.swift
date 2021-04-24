//
//  PlaylistPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol PlaylistPresenterProtocol: BasePresenter {
    var delegate: PlaylistViewControllerProtocol? { get set }
    
    func onOpenPlayer(playlist: AudioPlaylistProtocol)
    
    func onPlayerButtonClick(input: ApplicationInput)
    func onQuickOpenPlaylistButtonClick()
    func onPlayOrderButtonClick()
    
    func onPlaylistItemClick(index: UInt)
}

class PlaylistPresenter: PlaylistPresenterProtocol {
    weak var delegate: PlaylistViewControllerProtocol?
    
    private let audioInfo: AudioInfo
    private let playlist: AudioPlaylistProtocol
    private let options: OpenPlaylistOptions
    
    private var collectionDataSource: PlaylistViewDataSource?
    
    required init(audioInfo: AudioInfo, playlist: AudioPlaylistProtocol, options: OpenPlaylistOptions) {
        self.audioInfo = audioInfo
        
        // Sort playlist
        // Sort only playlists of type album
        let sorting = GeneralStorage.shared.getTrackSortingValue()
        let sortedPlaylist = playlist.isAlbumPlaylist() ? playlist.sortedPlaylist(withSorting: sorting) : playlist
        self.playlist = sortedPlaylist
        
        self.options = options
    }
    
    // PlaylistPresenterProtocol
    
    func start() {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        let dataSource = PlaylistViewDataSource(audioInfo: audioInfo, playlist: playlist, options: self.options)
        self.collectionDataSource = dataSource
        
        let audioPlayer = AudioPlayerService.shared
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
    
    func onOpenPlayer(playlist: AudioPlaylistProtocol) {
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
    
    func onQuickOpenPlaylistButtonClick() {
        if let playlist = AudioPlayerService.shared.playlist
        {
            delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist, options: self.options)
        }
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
    
    private func openPlayerScreen(_ track: AudioTrackProtocol) {
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
    
    private func playNewTrack(_ track: AudioTrackProtocol) {
        let player = AudioPlayerService.shared
        
        var playlistName = self.playlist.name
        var tracks = self.playlist.tracks
        
        // The playlist that will be played would be either the given playlist to the presenter
        // or the source playlist of the clicked track
        if self.options.openOriginalSourcePlaylist {
            if let source = track.originalSource.getSourcePlaylist(audioInfo: self.audioInfo, playingTrack: track) {
                playlistName = source.name
                tracks = source.tracks
            }
        }
        
        var playlist: AudioPlaylistProtocol!
        
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
    
    private func playFirstTime(playlist: AudioPlaylistProtocol) {
        playNew(playlist: playlist)
    }
    
    private func playNew(playlist: AudioPlaylistProtocol) {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        let player = AudioPlayerService.shared
        
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
