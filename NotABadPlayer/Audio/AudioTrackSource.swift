//
//  AudioTrackSource.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class AudioTrackSource: Codable, Equatable, Hashable {
    private static let cache: AudioTrackSourceCache = AudioTrackSourceCache()
    
    private let value : String
    private let isAlbumSource : Bool
    
    public static func createAlbumSource(albumID: Int) -> AudioTrackSource {
        let newSource = AudioTrackSource(value: "\(albumID)", isAlbumSource: true)
        return cache.getFlyweight(for: newSource)
    }
    
    public static func createPlaylistSource(playlistName: String) -> AudioTrackSource {
        let newSource = AudioTrackSource(value: playlistName, isAlbumSource: false)
        return cache.getFlyweight(for: newSource)
    }
    
    private init(value: String, isAlbumSource: Bool) {
        self.value = value
        self.isAlbumSource = isAlbumSource
    }
    
    func isAlbum() -> Bool {
        return self.isAlbumSource
    }
    
    func isPlaylist() -> Bool {
        return !isAlbum()
    }
    
    func getSourcePlaylist(audioInfo: AudioInfo, playingTrack: BaseAudioTrack) -> BaseAudioPlaylist? {
        if (isAlbum())
        {
            if let albumID = Int(value)
            {
                if let album = audioInfo.getAlbum(byID: albumID)
                {
                    let tracks = audioInfo.getAlbumTracks(album: album)
                    
                    do {
                        var node = AudioPlaylistBuilder.start()
                        node.name = album.albumTitle
                        node.tracks = tracks
                        node.playingTrack = playingTrack
                        
                        return try node.build()
                    } catch {
                        
                    }
                }
            }
            
            return nil
        }
        
        if (isPlaylist())
        {
            let userPlaylists = GeneralStorage.shared.getUserPlaylists()
            
            for playlist in userPlaylists
            {
                if value == playlist.name
                {
                    do {
                        var node = AudioPlaylistBuilder.start()
                        node.name = playlist.name
                        node.tracks = playlist.tracks
                        node.playingTrack = playingTrack
                        
                        return try node.build()
                    } catch {
                        
                    }
                }
            }
        }
        
        return nil
    }
    
    static func ==(lhs: AudioTrackSource, rhs: AudioTrackSource) -> Bool {
        return lhs.value == rhs.value && lhs.isAlbumSource == rhs.isAlbumSource
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
        hasher.combine(isAlbumSource)
    }
}

class AudioTrackSourceCache {
    private let lock : NSObject = NSObject()
    
    private var sourceCache: Set<AudioTrackSource> = []
    
    public func getFlyweight(for source: AudioTrackSource) -> AudioTrackSource {
        lockEnter()
        
        defer {
            lockExit()
        }
        
        // If already present in cache, return cached instance
        for cachedSource in sourceCache {
            if cachedSource == source {
                return cachedSource
            }
        }
        
        // Otherwise add given value to cache and return it
        sourceCache.insert(source)
        
        return source
    }
    
    private func lockEnter() {
        objc_sync_enter(self.lock)
    }
    
    private func lockExit() {
        objc_sync_exit(self.lock)
    }
}
