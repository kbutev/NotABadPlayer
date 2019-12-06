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

enum AudioPlaylistError: Error {
    case invalidArgument(String)
}

class MutableAudioPlaylist: BaseAudioPlaylist, Codable {
    public let name: String
    
    private(set) var tracks: [AudioTrack]
    private(set) var firstTrack: AudioTrack
    
    private(set) var isPlaying: Bool = false
    private(set) var playingTrackPosition: Int
    
    public var playingTrack: AudioTrack {
        get {
            return self.tracks[self.playingTrackPosition]
        }
    }
    
    public var isTemporary: Bool = false
    
    init(name: String, tracks: [AudioTrack]) {
        guard let firstTrack = tracks.first else {
            fatalError("Given Playlist Track Must Not Be Empty")
        }
        
        self.name = name;
        self.tracks = []
        self.tracks.append(tracks[0]) // Add one track just so we can determine isAlbumPlaylist()
        self.firstTrack = firstTrack
        self.playingTrackPosition = 0
        
        // Make sure that all tracks have the correct source
        let isAlbumList = isAlbumPlaylist()
        self.tracks.removeAll()
        
        let theSource = isAlbumList ? AudioTrackSource.createAlbumSource(albumID: firstTrack.albumID) : AudioTrackSource.createPlaylistSource(playlistName: self.name)
        
        for e in 0..<tracks.count
        {
            let track = tracks[e]
            
            if track.source == theSource {
                self.tracks.append(track)
                continue
            }
            
            var node = AudioTrackBuilder.start(prototype: track)
            node.source = theSource
            
            do {
                let result = try node.build()
                self.tracks.append(result)
            } catch {
                let path = track.filePath?.absoluteString ?? ""
                Logging.log(MutableAudioPlaylist.self, "Failed to copy audio track \(path)")
            }
        }
    }
    
    convenience init(name: String, startWithTrack: AudioTrack) {
        self.init(name: name, tracks: [startWithTrack])
        
        self.goToTrack(startWithTrack)
    }
    
    convenience init(name: String, tracks: [AudioTrack], startWithTrack: AudioTrack?) throws {
        try self.init(name: name, tracks: tracks, startWithTrack: startWithTrack, sorting: .NONE)
    }
    
    convenience init(name: String, tracks: [AudioTrack], sorting: TrackSorting) {
        self.init(name: name, tracks: MediaSorting.sortTracks(tracks, sorting: sorting))
    }
    
    convenience init(name: String, tracks: [AudioTrack], startWithTrack: AudioTrack?, sorting: TrackSorting) throws {
        self.init(name: name, tracks: MediaSorting.sortTracks(tracks, sorting: sorting))
        
        if let startingTrack = startWithTrack
        {
            if self.hasTrack(startingTrack)
            {
                self.goToTrack(startingTrack)
            }
            else
            {
                throw AudioPlaylistError.invalidArgument("Playlist cannot start with given track, was not found in the given tracks")
            }
        }
    }
    
    static func == (lhs: MutableAudioPlaylist, rhs: MutableAudioPlaylist) -> Bool {
        return lhs.name == rhs.name && lhs.playingTrackPosition == rhs.playingTrackPosition && lhs.tracks == rhs.tracks
    }
    
    func equals(_ other: BaseAudioPlaylist) -> Bool {
        if let other_ = other as? MutableAudioPlaylist {
            return self == other_
        }
        
        return false
    }
    
    func sortedPlaylist(withSorting sorting: TrackSorting) -> MutableAudioPlaylist {
        let playlist = MutableAudioPlaylist(name: name, tracks: tracks, sorting: sorting)
        playlist.goToTrack(playingTrack)
        return playlist
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
        return playingTrackPosition + 1 == tracks.count
    }
    
    func hasTrack(_ track: AudioTrack) -> Bool {
        return tracks.index(of: track) != nil
    }
    
    func playCurrent() {
        isPlaying = true
    }
    
    func goToTrack(_ track: AudioTrack) {
        if let index = tracks.index(of: track)
        {
            isPlaying = true
            playingTrackPosition = index
        }
    }
    
    func goToTrackAt(_ index: Int) {
        if index >= 0 && index < tracks.count {
            isPlaying = true
            playingTrackPosition = index
        }
    }
    
    func goToTrackBasedOnPlayOrder(playOrder: AudioPlayOrder) {
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
    
    func goToNextPlayingTrack() {
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
    
    func goToNextPlayingTrackRepeat() {
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
    
    func goToPreviousPlayingTrack() {
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
    
    func goToTrackByShuffle() {
        isPlaying = true
        
        let min = 0
        let max = tracks.count - 1
        playingTrackPosition = Int.random(in: min...max)
    }
    
    // Serialization keys
    internal enum CodingKeys: String, CodingKey {
        case name
        case tracks
        case firstTrack
        case isPlaying
        case playingTrackPosition
    }
}
