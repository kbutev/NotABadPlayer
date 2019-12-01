//
//  AudioLibrary.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

// Provides simple interface to the audio library of the user.
// Dependant on storage access permission:
// Make sure you have access to user storage before using the audio library.
class AudioLibrary : AudioInfo {
    private let lock : NSObject = NSObject()
    
    private var loadedAlbums : Bool = false
    private var albums : [AudioAlbum] = []
    
    init() {
        
    }
    
    public func loadIfNecessary() {
        lockEnter()
        
        if self.loadedAlbums {
            return
        }
        
        lockExit()
        
        load()
    }
    
    public func load() {
        // Thread safe
        lockEnter()
        
        defer {
            lockExit()
        }
        
        // Load albums
        Logging.log(AudioLibrary.self, "Loading albums from MP media...")
        
        loadedAlbums = true
        
        albums.removeAll()
        
        let newAlbums: NSMutableArray = NSMutableArray()
        
        let mediaQuery: MPMediaQuery = MPMediaQuery.albums()
        
        guard let allAlbums = mediaQuery.collections else
        {
            return
        }
        
        for collection: MPMediaItemCollection in allAlbums
        {
            if let item = collection.items.first
            {
                let albumId = item.value(forProperty: MPMediaItemPropertyAlbumPersistentID) as! NSNumber
                let albumTitle = item.value(forKey: MPMediaItemPropertyAlbumTitle) as? String ?? "<Unknown>"
                let artist = item.value(forKey: MPMediaItemPropertyArtist) as? String ?? "<Unknown>"
                let albumCover = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                
                let album = AudioAlbum(albumID: albumId,
                                       albumArtist: artist,
                                       albumTitle: albumTitle,
                                       albumCover: albumCover)
                
                newAlbums.add(album)
            }
        }
        
        albums = newAlbums as NSArray as! [AudioAlbum]
        
        Logging.log(AudioLibrary.self, "Successfully loaded \(albums.count) albums from MP media.")
    }
    
    func getAlbums() -> [AudioAlbum] {
        // Thread safe
        lockEnter()
        
        if self.loadedAlbums
        {
            return albums
        }
        
        lockExit()
        
        load()
        
        return albums
    }
    
    func getAlbum(byID identifier: Int) -> AudioAlbum? {
        return getAlbums().first(where: {album in
            return album.albumID == identifier
        })
    }
    
    func getAlbumTracks(album: AudioAlbum) -> [AudioTrack] {
        var tracks: [AudioTrack] = []
        
        let mediaQuery = MPMediaQuery.songs()
        let predicate = MPMediaPropertyPredicate.init(value: album.albumID, forProperty: MPMediaItemPropertyAlbumPersistentID)
        mediaQuery.addFilterPredicate(predicate)
        
        guard let allSongs = mediaQuery.items else
        {
            return []
        }
        
        for item in allSongs
        {
            guard let identifier = item.value(forProperty: MPMediaItemPropertyPersistentID) as? Int else {
                continue
            }
            
            guard let path = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL else {
                continue
            }
            
            let title = item.value(forProperty: MPMediaItemPropertyTitle) as? String ?? "<Unknown>"
            let artist = item.value(forProperty: MPMediaItemPropertyArtist) as? String ?? "<Unknown>"
            let trackNum_ = item.value(forProperty: MPMediaItemPropertyAlbumTrackNumber) as? NSNumber
            let durationInSeconds_ = item.value(forProperty: MPMediaItemPropertyPlaybackDuration) as? NSNumber
            let albumCover = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            
            guard let trackNum = trackNum_?.intValue else {
                continue
            }
            
            guard let durationInSeconds = durationInSeconds_?.doubleValue else {
                continue
            }
            
            var node = AudioTrackBuilder.start()
            node.identifier = identifier
            node.filePath = path
            node.title = title
            node.artist = artist
            node.albumTitle = album.albumTitle
            node.albumID = album.albumID
            node.albumCover = albumCover
            node.trackNum = trackNum
            node.durationInSeconds = durationInSeconds
            node.source = AudioTrackSource.createAlbumSource(albumID: album.albumID)
            
            do {
                let result = try node.build()
                tracks.append(result)
            } catch {
                
            }
        }
        
        return tracks
    }
    
    func searchForTracks(query: String) -> [AudioTrack] {
        var tracks: [AudioTrack] = []
        
        let mediaQuery = MPMediaQuery.songs()
        
        let predicate = MPMediaPropertyPredicate.init(value: query, forProperty: MPMediaItemPropertyTitle, comparisonType: .contains)
        mediaQuery.addFilterPredicate(predicate)
        
        guard let result = mediaQuery.items else
        {
            return []
        }
        
        for item in result
        {
            guard let identifier = item.value(forProperty: MPMediaItemPropertyPersistentID) as? Int else {
                continue
            }
            
            guard let path = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL else {
                continue
            }
            
            let albumId_ = item.value(forProperty: MPMediaItemPropertyAlbumPersistentID) as! NSNumber
            let albumTitle = item.value(forKey: MPMediaItemPropertyAlbumTitle) as? String ?? "<Unknown>"
            let artist = item.value(forKey: MPMediaItemPropertyArtist) as? String ?? "<Unknown>"
            let albumCover = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            
            let title = item.value(forProperty: MPMediaItemPropertyTitle) as? String ?? "<Unknown>"
            let trackNum_ = item.value(forProperty: MPMediaItemPropertyAlbumTrackNumber) as? NSNumber
            let durationInSeconds_ = item.value(forProperty: MPMediaItemPropertyPlaybackDuration) as? NSNumber
            
            let albumID = albumId_.intValue
            
            guard let trackNum = trackNum_?.intValue else {
                continue
            }
            
            guard let durationInSeconds = durationInSeconds_?.doubleValue else {
                continue
            }
            
            var node = AudioTrackBuilder.start()
            node.identifier = identifier
            node.filePath = path
            node.title = title
            node.artist = artist
            node.albumTitle = albumTitle
            node.albumID = albumID
            node.albumCover = albumCover
            node.trackNum = trackNum
            node.durationInSeconds = durationInSeconds
            node.source = AudioTrackSource.createAlbumSource(albumID: albumID)
            
            do {
                let result = try node.build()
                tracks.append(result)
            } catch {
                
            }
        }
        
        return tracks
    }
    
    private func lockEnter() {
        objc_sync_enter(self.lock)
    }
    
    private func lockExit() {
        objc_sync_exit(self.lock)
    }
}
