//
//  SafeMutableAudioPlaylist.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 5.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class SafeMutableAudioPlaylist: MutableAudioPlaylist {
    private let _lock = NSLock()
    
    private let _write: MutableAudioPlaylist
    private var _read: MutableAudioPlaylist
    
    public static func build(_ prototype: MutableAudioPlaylist) throws -> SafeMutableAudioPlaylist {
        return try SafeMutableAudioPlaylist(prototype)
    }
    
    public init(_ prototype: MutableAudioPlaylist) throws {
        _write = try AudioPlaylistBuilder.buildMutableFromImmutable(prototype: prototype)
        _read = try AudioPlaylistBuilder.buildMutableFromImmutable(prototype: prototype)
        super.init(name: prototype.name, tracks: prototype.tracks)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func copy() -> MutableAudioPlaylist {
        var read: MutableAudioPlaylist!
        
        lock()
        read = self._read
        unlock()
        
        return read
    }
    
    override public var isPlaying: Bool {
        get {
            var read: MutableAudioPlaylist!
            lock()
            read = self._read
            unlock()
            return read.isPlaying
        }
    }
    override public var playingTrackPosition: Int {
        get {
            var read: MutableAudioPlaylist!
            lock()
            read = self._read
            unlock()
            return read.playingTrackPosition
        }
    }
    
    override public var playingTrack: AudioTrack {
        get {
            var read: MutableAudioPlaylist!
            lock()
            read = self._read
            unlock()
            return read.playingTrack
        }
    }
    
    override public var isTemporary: Bool {
        get {
            var read: MutableAudioPlaylist!
            lock()
            read = self._read
            unlock()
            return read.isTemporary
        }
        set {
            lock()
            self._write.isTemporary = newValue
            updateReadPlaylist()
            unlock()
        }
    }
    
    override func sortedPlaylist(withSorting sorting: TrackSorting) -> MutableAudioPlaylist {
        var read: MutableAudioPlaylist!
        
        lock()
        read = self._read
        unlock()
        
        return read.sortedPlaylist(withSorting: sorting)
    }
    
    override func isAlbumPlaylist() -> Bool {
        var read: MutableAudioPlaylist!
        
        lock()
        read = self._read
        unlock()
        
        return read.name == read.firstTrack.albumTitle
    }
    
    override func size() -> Int {
        var read: MutableAudioPlaylist!
        
        lock()
        read = self._read
        unlock()
        
        return read.tracks.count
    }
    
    override func trackAt(_ index: Int) -> AudioTrack {
        var read: MutableAudioPlaylist!
        
        lock()
        read = self._read
        unlock()
        
        return read.tracks[index]
    }
    
    override func getAlbum(audioInfo: AudioInfo) -> AudioAlbum? {
        var read: MutableAudioPlaylist!
        
        lock()
        read = self._read
        unlock()
        
        for track in read.tracks
        {
            if let album = audioInfo.getAlbum(byID: track.albumID)
            {
                return album
            }
        }
        
        return nil
    }
    
    override func isPlayingFirstTrack() -> Bool {
        var read: MutableAudioPlaylist!
        
        lock()
        read = self._read
        unlock()
        
        return read.playingTrackPosition == 0
    }
    
    override func isPlayingLastTrack() -> Bool {
        var read: MutableAudioPlaylist!
        
        lock()
        read = self._read
        unlock()
        
        return read.playingTrackPosition + 1 == read.tracks.count
    }
    
    override func hasTrack(_ track: AudioTrack) -> Bool {
        var read: MutableAudioPlaylist!
        
        lock()
        read = self._read
        unlock()
        
        return read.tracks.index(of: track) != nil
    }
    
    override func playCurrent() {
        lock()
        self._write.playCurrent()
        self.updateReadPlaylist()
        unlock()
    }
    
    override func goToTrack(_ track: AudioTrack) {
        lock()
        self._write.goToTrack(track)
        self.updateReadPlaylist()
        unlock()
    }
    
    override func goToTrackAt(_ index: Int) {
        lock()
        self._write.goToTrackAt(index)
        self.updateReadPlaylist()
        unlock()
    }
    
    override func goToTrackBasedOnPlayOrder(playOrder: AudioPlayOrder) {
        lock()
        self._write.goToTrackBasedOnPlayOrder(playOrder: playOrder)
        self.updateReadPlaylist()
        unlock()
    }
    
    override func goToNextPlayingTrack() {
        lock()
        self._write.goToNextPlayingTrack()
        self.updateReadPlaylist()
        unlock()
    }
    
    override func goToNextPlayingTrackRepeat() {
        lock()
        self._write.goToNextPlayingTrackRepeat()
        self.updateReadPlaylist()
        unlock()
    }
    
    override func goToPreviousPlayingTrack() {
        lock()
        self._write.goToPreviousPlayingTrack()
        self.updateReadPlaylist()
        unlock()
    }
    
    override func goToTrackByShuffle() {
        lock()
        self._write.goToTrackByShuffle()
        self.updateReadPlaylist()
        unlock()
    }
    
    private func lock() {
        _lock.lock()
    }
    
    private func unlock() {
        _lock.unlock()
    }
    
    private func updateReadPlaylist() {
        do {
            _read = try AudioPlaylistBuilder.buildMutableFromImmutable(prototype: _write)
        } catch {
            
        }
    }
}
