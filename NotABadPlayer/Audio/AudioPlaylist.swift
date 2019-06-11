//
//  AudioPlaylist.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

enum AudioPlayOrder: String, Codable {
    case ONCE;
    case ONCE_FOREVER;
    case FORWARDS;
    case FORWARDS_REPEAT;
    case SHUFFLE;
}

struct AudioPlaylist: Codable {
    public let name: String
    
    private (set) var tracks: [AudioTrack]
    private (set) var firstTrack: AudioTrack
    
    private (set) var isPlaying: Bool = false
    private (set) var playingTrackPosition: Int
    
    public var playingTrack: AudioTrack {
        get {
            return self.tracks[self.playingTrackPosition]
        }
    }
    
    init(name: String, startWithTrack: AudioTrack) {
        self.init(name: name, tracks: [startWithTrack], startWithTrack: startWithTrack)
    }
    
    init(name: String, tracks: [AudioTrack]) {
        self.init(name: name, tracks: tracks, startWithTrack: nil)
    }
    
    init(name: String, tracks: [AudioTrack], startWithTrack: AudioTrack?, sorting: TrackSorting) {
        let sortedTracks = MediaSorting.sortTracks(tracks, sorting: sorting)
        self.init(name: name, tracks: sortedTracks, startWithTrack: startWithTrack)
    }
    
    init(name: String, tracks: [AudioTrack], startWithTrack: AudioTrack?) {
        guard let firstTrack = tracks.first else {
            fatalError("Given Playlist Track Must Not Be Empty")
        }
        
        self.name = name;
        self.tracks = tracks
        self.firstTrack = firstTrack
        self.playingTrackPosition = 0
        
        // Set proper source value
        let isAlbumList = isAlbumPlaylist()
        self.tracks = []
        
        for e in 0..<tracks.count
        {
            let source = isAlbumList ? AudioTrackSource.createAlbumSource(albumID: firstTrack.albumID) : AudioTrackSource.createPlaylistSource(playlistName: self.name)
            
            self.tracks.append(AudioTrack(originalTrack: tracks[e], source: source))
        }
        
        if let playingTrack = startWithTrack
        {
            for e in 0..<tracks.count
            {
                if self.tracks[e] == playingTrack
                {
                    self.playingTrackPosition = e
                    break
                }
            }
        }
    }
    
    func sortedPlaylist(withSorting sorting: TrackSorting) -> AudioPlaylist {
        return AudioPlaylist(name: name, tracks: tracks, startWithTrack: playingTrack, sorting: sorting)
    }
    
    func isAlbumPlaylist() -> Bool {
        return self.name == firstTrack.albumTitle
    }
    
    func size() -> Int {
        return self.tracks.count
    }
    
    func trackAt(_ index: Int) -> AudioTrack {
        return self.tracks[index]
    }
    
    func getAlbum(audioInfo: AudioInfo) -> AudioAlbum? {
        for track in tracks
        {
            if let album = audioInfo.getAlbum(byID: track.albumID)
            {
                return album
            }
        }
        
        return nil
    }
    
    func isPlayingFirstTrack() -> Bool {
        return playingTrackPosition == 0
    }
    
    func isPlayingLastTrack() -> Bool {
        return playingTrackPosition == tracks.count
    }
    
    mutating func playCurrent() {
        isPlaying = true
    }
    
    mutating func goToTrack(track: AudioTrack) {
        if let index = tracks.index(of: track)
        {
            isPlaying = true
            playingTrackPosition = index
        }
    }
    
    mutating func goToTrackBasedOnPlayOrder(playOrder: AudioPlayOrder) {
        isPlaying = true
        
        switch playOrder
        {
        case .ONCE:
            isPlaying = false
            break
        case .ONCE_FOREVER:
            break
        case .FORWARDS:
            goToNextPlayingTrack()
            break
        case .FORWARDS_REPEAT:
            goToNextPlayingTrackRepeat()
            break
        case .SHUFFLE:
            goToTrackByShuffle()
            break
        }
    }
    
    mutating func goToNextPlayingTrack() {
        isPlaying = true
        
        // Stop playing upon reaching the end
        if (isPlayingLastTrack())
        {
            isPlaying = false
        }
        else
        {
            playingTrackPosition += 1
        }
    }
    
    mutating func goToNextPlayingTrackRepeat() {
        isPlaying = true
        
        // Keep going until reaching the end
        // Once the end is reached, jump to the first track to loop the list again
        if (!isPlayingLastTrack())
        {
            goToNextPlayingTrack()
        }
        else
        {
            playingTrackPosition = 0
        }
    }
    
    mutating func goToPreviousPlayingTrack() {
        isPlaying = true
        
        if (isPlayingFirstTrack())
        {
            playingTrackPosition = 0
            isPlaying = false
        }
        else
        {
            playingTrackPosition -= 1
        }
    }
    
    mutating func goToTrackByShuffle() {
        isPlaying = true
        
        let min = 0
        let max = tracks.count - 1
        playingTrackPosition = Int.random(in: min...max)
    }
}
