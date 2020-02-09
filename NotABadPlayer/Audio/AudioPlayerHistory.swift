//
//  AudioPlayerHistory.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol AudioPlayerHistory: AnyObject {
    var playHistory: [AudioTrack] { get set }
    
    func addToPlayHistory(newTrack: AudioTrack)
    func playPreviousInPlayHistory()
}

class AudioPlayerHistoryStandard: AudioPlayerHistory {
    private let synchronous: DispatchQueue = DispatchQueue(label: "AudioPlayerHistory.synchronous")
    
    private var _playHistory: [AudioTrack] = []
    
    var playHistory: [AudioTrack] {
        get {
            return synchronous.sync {
                return _playHistory
            }
        }
        set {
            synchronous.sync {
                _playHistory = newValue
            }
        }
    }
    
    private weak var player: AudioPlayer?
    
    init() {
        self.player = nil
    }
    
    init(player: AudioPlayer) {
        self.player = player
    }
    
    func addToPlayHistory(newTrack: AudioTrack) {
        let capacity = GeneralStorage.shared.getPlayerPlayedHistoryCapacity()
        
        synchronous.sync {
            // Make sure that the history tracks are unique
            _playHistory.removeAll(where: { (element) -> Bool in element == newTrack})
            
            _playHistory.insert(newTrack, at: 0)
            
            // Do not exceed the play history capacity
            
            while _playHistory.count > capacity
            {
                _playHistory.removeLast()
            }
        }
    }
    
    func playPreviousInPlayHistory() {
        guard let player = self.player else
        {
            return
        }
        
        player.stop()
        
        if (self.playHistory.count <= 1)
        {
            return
        }
        
        var first: AudioTrack?
        
        synchronous.sync {
            _playHistory.removeFirst()
            first = _playHistory.first
        }
        
        guard let previousTrack = first else {
            return
        }
        
        var newPlaylist = previousTrack.source.getSourcePlaylist(audioInfo: player.audioInfo, playingTrack: previousTrack)
        
        if newPlaylist == nil
        {
            let playlistName = Text.value(.PlaylistRecentlyPlayed)
            
            var node = AudioPlaylistBuilder.start()
            node.name = playlistName
            node.playingTrack = previousTrack
            
            do {
                newPlaylist = try node.build()
            } catch {
                Logging.log(AudioPlayer.self, "Error: failed to build playlist from previous track")
                newPlaylist = nil
            }
        }
        
        // Play playlist with specific track from play history
        if let resultPlaylist = newPlaylist
        {
            do {
                try player.play(playlist: resultPlaylist)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play previous in play history, \(error.localizedDescription)")
                player.stop()
                return
            }
        }
    }
}
