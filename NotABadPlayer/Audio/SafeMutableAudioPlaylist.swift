//
//  SafeMutableAudioPlaylist.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 5.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

// Wraps a single playlist that can be mutated at any time.
// Very memory/cpu effecient, use copy() to quickly get a copy of the latest playlist data.
// Thread safe: yes
class SafeMutableAudioPlaylist: MutableAudioPlaylist {
    private let _lock = NSLock()
    
    private let _write: MutableAudioPlaylist
    private var _read: MutableAudioPlaylist
    
    public static func build(_ prototype: MutableAudioPlaylist) throws -> SafeMutableAudioPlaylist {
        return try SafeMutableAudioPlaylist(prototype: prototype)
    }
    
    private init(prototype: MutableAudioPlaylist) throws {
        _write = try AudioPlaylistBuilder.buildMutableFromImmutable(prototype: prototype)
        _read = try AudioPlaylistBuilder.buildMutableFromImmutable(prototype: prototype)
        super.init(prototype)
    }
    
    required init(from decoder: Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    public func copy() -> MutableAudioPlaylist {
        lock()
        let list = _read
        unlock()
        return list
    }
    
    override public var isPlaying: Bool {
        get {
            lock()
            let read = self._read
            unlock()
            return read.isPlaying
        }
    }
    override public var playingTrackPosition: Int {
        get {
            lock()
            let read = self._read
            unlock()
            return read.playingTrackPosition
        }
    }
    
    override public var playingTrack: AudioTrackProtocol {
        get {
            lock()
            let read = self._read
            unlock()
            return read.playingTrack
        }
    }
    
    override public var isTemporary: Bool {
        get {
            lock()
            let read = self._read
            unlock()
            return read.isTemporary
        }
    }
    
    override func sortedPlaylist(withSorting sorting: TrackSorting) -> MutableAudioPlaylist {
        lock()
        let read = self._read
        unlock()
        
        return read.sortedPlaylist(withSorting: sorting)
    }
    
    override func isAlbumPlaylist() -> Bool {
        lock()
        let read = self._read
        unlock()
        
        return read.name == read.firstTrack.albumTitle
    }
    
    override func size() -> Int {
        lock()
        let read = self._read
        unlock()
        
        return read.tracks.count
    }
    
    override func trackAt(_ index: Int) -> AudioTrackProtocol {
        lock()
        let read = self._read
        unlock()
        
        return read.trackAt(index)
    }
    
    override func getAlbum(audioInfo: AudioInfo) -> AudioAlbum? {
        lock()
        let read = self._read
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
        lock()
        let read = self._read
        unlock()
        
        return read.playingTrackPosition == 0
    }
    
    override func isPlayingLastTrack() -> Bool {
        lock()
        let read = self._read
        unlock()
        
        return read.playingTrackPosition + 1 == read.tracks.count
    }
    
    override func hasTrack(_ track: AudioTrackProtocol) -> Bool {
        lock()
        let read = self._read
        unlock()
        
        return read.hasTrack(track)
    }
    
    override func playCurrent() {
        lock()
        self._write.playCurrent()
        unlock()
        self.updateReadPlaylist()
    }
    
    override func goToTrack(_ track: AudioTrackProtocol) {
        lock()
        self._write.goToTrack(track)
        unlock()
        self.updateReadPlaylist()
    }
    
    override func goToTrackAt(_ index: Int) {
        lock()
        self._write.goToTrackAt(index)
        unlock()
        self.updateReadPlaylist()
    }
    
    override func goToTrackBasedOnPlayOrder(playOrder: AudioPlayOrder) {
        lock()
        self._write.goToTrackBasedOnPlayOrder(playOrder: playOrder)
        unlock()
        self.updateReadPlaylist()
    }
    
    override func goToNextPlayingTrack() {
        lock()
        self._write.goToNextPlayingTrack()
        unlock()
        self.updateReadPlaylist()
    }
    
    override func goToNextPlayingTrackRepeat() {
        lock()
        self._write.goToNextPlayingTrackRepeat()
        unlock()
        self.updateReadPlaylist()
    }
    
    override func goToPreviousPlayingTrack() {
        lock()
        self._write.goToPreviousPlayingTrack()
        unlock()
        self.updateReadPlaylist()
    }
    
    override func goToTrackByShuffle() {
        lock()
        self._write.goToTrackByShuffle()
        unlock()
        self.updateReadPlaylist()
    }
    
    private func updateReadPlaylist() {
        lock()
        do {
            _read = try AudioPlaylistBuilder.buildMutableFromImmutable(prototype: _write)
        } catch {
            
        }
        unlock()
    }
    
    private func lock() {
        _lock.lock()
    }
    
    private func unlock() {
        _lock.unlock()
    }
}
