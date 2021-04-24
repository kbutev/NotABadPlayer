//
//  AudioPlaylist.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

enum AudioPlayOrder: String, Codable {
    case ONCE
    case ONCE_FOREVER
    case FORWARDS
    case FORWARDS_REPEAT
    case SHUFFLE
}

enum AudioPlaylistError: Error {
    case invalidArgument(String)
}

class MutableAudioPlaylist: AudioPlaylistProtocol, Codable {
    private var _name: String
    private var _tracks: [AudioTrackProtocol]
    
    private var _playing: Bool = false
    private var _playingTrackPosition: Int
    private var _temporary: Bool = false
    
    public var name: String {
        get {
            return _name
        }
    }
    public var tracks: [AudioTrackProtocol] {
        get {
            return _tracks
        }
    }
    public var firstTrack: AudioTrackProtocol {
        get {
            return _tracks[0]
        }
    }
    public var isPlaying: Bool {
        get {
            return _playing
        }
    }
    public var playingTrackPosition: Int {
        get {
            return _playingTrackPosition
        }
    }
    
    public var playingTrack: AudioTrackProtocol {
        get {
            return self.tracks[self.playingTrackPosition]
        }
    }
    
    public var isTemporary: Bool {
        get {
            return _temporary
        }
    }
    
    init(_ prototype: MutableAudioPlaylist) {
        self._name = prototype.name
        self._tracks = prototype.tracks
        self._playingTrackPosition = prototype.playingTrackPosition
        self._playing = prototype.isPlaying
        self._temporary = prototype.isTemporary
    }
    
    init(name: String,
         tracks: [AudioTrackProtocol],
         startWithTrackIndex: Int,
         startPlaying: Bool,
         isTemporary: Bool) throws {
        guard let firstTrack = tracks.first else {
            fatalError("Given Playlist Track Must Not Be Empty")
        }
        
        self._name = name
        self._tracks = []
        self._playingTrackPosition = 0
        
        // Is album list?
        self._tracks.append(tracks[0]) // Add one track just so we can determine isAlbumPlaylist()
        let isAlbumList = isAlbumPlaylist()
        self._tracks.removeAll()
        
        // Make sure that all tracks have the correct source
        let theSource = isAlbumList ? AudioTrackSource.createAlbumSource(albumID: firstTrack.albumID) : AudioTrackSource.createPlaylistSource(playlistName: self.name)
        
        for e in 0..<tracks.count
        {
            let track = tracks[e]
            
            if track.source == theSource {
                self._tracks.append(track)
                continue
            }
            
            var node = AudioTrackBuilder.start(prototype: track)
            node.source = theSource
            
            do {
                let result = try node.build()
                self._tracks.append(result)
            } catch {
                let path = track.filePath.absoluteString
                Logging.log(MutableAudioPlaylist.self, "Failed to copy audio track \(path)")
            }
        }
        
        if startWithTrackIndex < 0 || startWithTrackIndex >= tracks.count
        {
            throw AudioPlaylistError.invalidArgument("Playlist cannot start with given track index, its invalid: \(startWithTrackIndex)/\(tracks.count)")
        }
        
        _playing = startPlaying
        _playingTrackPosition = startWithTrackIndex
        _playing = startPlaying
        _temporary = isTemporary
    }
    
    convenience init(name: String, tracks: [AudioTrackProtocol]) throws {
        try self.init(name: name,
                      tracks: tracks,
                      startWithTrackIndex: 0,
                      startPlaying: false,
                      isTemporary: false)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self._name = try container.decode(String.self, forKey: ._name)
        self._tracks = try container.decode([AudioTrackBuilderLatestVersion].self, forKey: ._tracks)
        self._playing = try container.decode(Bool.self, forKey: ._playing)
        self._playingTrackPosition = try container.decode(Int.self, forKey: ._playingTrackPosition)
        self._temporary = try container.decode(Bool.self, forKey: ._temporary)
    }
    
    static func == (lhs: MutableAudioPlaylist, rhs: MutableAudioPlaylist) -> Bool {
        return lhs.name == rhs.name && lhs.playingTrackPosition == rhs.playingTrackPosition && lhs.tracks == rhs.tracks
    }
    
    func equals(_ other: AudioPlaylistProtocol) -> Bool {
        if let other_ = other as? MutableAudioPlaylist {
            return self == other_
        }
        
        return false
    }
    
    func sortedPlaylist(withSorting sorting: TrackSorting) -> MutableAudioPlaylist {
        let tracks = MediaSorting.sortTracks(_tracks, sorting: sorting)
        
        do {
            let playlist = try MutableAudioPlaylist(name: name,
                                                    tracks: tracks,
                                                    startWithTrackIndex: playingTrackPosition,
                                                    startPlaying: isPlaying,
                                                    isTemporary: isTemporary)
            return playlist
        } catch {
            // This should never fail, but we need to handle this case
            return self
        }
    }
    
    func isAlbumPlaylist() -> Bool {
        return self.name == self.firstTrack.albumTitle
    }
    
    func size() -> Int {
        return self.tracks.count
    }
    
    func trackAt(_ index: Int) -> AudioTrackProtocol {
        return self.tracks[index]
    }
    
    func getAlbum(audioInfo: AudioInfo) -> AudioAlbum? {
        for track in self.tracks
        {
            if let album = audioInfo.getAlbum(byID: track.albumID)
            {
                return album
            }
        }
        
        return nil
    }
    
    func isPlayingFirstTrack() -> Bool {
        return self.playingTrackPosition == 0
    }
    
    func isPlayingLastTrack() -> Bool {
        return self.playingTrackPosition + 1 == self.tracks.count
    }
    
    func hasTrack(_ track: AudioTrackProtocol) -> Bool {
        return self.tracks.index(of: track) != nil
    }
    
    func playCurrent() {
        _playing = true
    }
    
    func goToTrack(_ track: AudioTrackProtocol) {
        if let index = _tracks.index(of: track)
        {
            _playing = true
            _playingTrackPosition = index
        }
    }
    
    func goToTrackAt(_ index: Int) {
        if index >= 0 && index < _tracks.count {
            _playing = true
            _playingTrackPosition = index
        }
    }
    
    func goToTrackBasedOnPlayOrder(playOrder: AudioPlayOrder) {
        _playing = true
        
        switch playOrder
        {
        case .ONCE:
            _playing = false
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
        _playing = true
        
        // Stop playing upon reaching the end
        if (isPlayingLastTrack())
        {
            _playing = false
        }
        else
        {
            _playingTrackPosition += 1
        }
    }
    
    func goToNextPlayingTrackRepeat() {
        _playing = true
        
        // Keep going until reaching the end
        // Once the end is reached, jump to the first track to loop the list again
        if (!isPlayingLastTrack())
        {
            goToNextPlayingTrack()
        }
        else
        {
            _playingTrackPosition = 0
        }
    }
    
    func goToPreviousPlayingTrack() {
        _playing = true
        
        if (isPlayingFirstTrack())
        {
            _playingTrackPosition = 0
            _playing = false
        }
        else
        {
            _playingTrackPosition -= 1
        }
    }
    
    func goToTrackByShuffle() {
        _playing = true
        
        let min = 0
        let max = _tracks.count - 1
        _playingTrackPosition = Int.random(in: min...max)
    }
    
    // Serialization keys
    internal enum CodingKeys: String, CodingKey {
        case _name
        case _tracks
        case _playing
        case _playingTrackPosition
        case _temporary
    }
}
