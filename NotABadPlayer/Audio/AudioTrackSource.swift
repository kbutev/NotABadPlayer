//
//  AudioTrackSource.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

struct AudioTrackSource: Codable {
    private let value : String
    private let isAlbumSource : Bool
    
    public static func createAlbumSource(albumID: NSNumber) -> AudioTrackSource {
        return AudioTrackSource(value: albumID.stringValue, isAlbumSource: true)
    }
    
    public static func createPlaylistSource(playlistName: String) -> AudioTrackSource {
        return AudioTrackSource(value: playlistName, isAlbumSource: false)
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
    
    func getSourcePlaylist(audioInfo: AudioInfo, playingTrack: AudioTrack) -> AudioPlaylist? {
        if (isAlbum())
        {
            
        }
        
        if (isPlaylist())
        {
            
        }
        
        return nil
    }
}
