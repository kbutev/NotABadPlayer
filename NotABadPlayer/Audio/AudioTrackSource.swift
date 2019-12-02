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
    
    public static func createAlbumSource(albumID: Int) -> AudioTrackSource {
        return AudioTrackSource(value: "\(albumID)", isAlbumSource: true)
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
    
    func getSourcePlaylist(audioInfo: AudioInfo, playingTrack: AudioTrack) -> BaseAudioPlaylist? {
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
}
