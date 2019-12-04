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
    public static let RECENTLY_ADDED_DAYS_DIFFERENCE = 30
    
    private let lock : NSObject = NSObject()
    private let internalQueue: DispatchQueue
    
    private var loadedAlbums : Bool = false
    private var albums : [AudioAlbum] = []
    
    private var loadedRecentlyAdded : Bool = false
    private var recentlyAdded : [AudioTrack] = []
    
    init() {
        internalQueue = DispatchQueue(label: "AudioLibrary.internalQueue")
    }
    
    public func loadIfNecessary() {
        var hasLoadedAlbums = false
        
        lockEnter()
        
        hasLoadedAlbums = self.loadedAlbums
        
        lockExit()
        
        if !hasLoadedAlbums {
            load()
        }
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
    
    public func loadRecentlyAddedTracks() {
        lockEnter()
        
        defer {
            lockExit()
        }
        
        self.recentlyAdded.removeAll()
        
        let allTracks = MPMediaQuery.songs()
        
        let tracks: [AudioTrack] = searchForTracks(mediaQuery: allTracks, predicate: nil)
        
        let now = Date()
        let minimumDate = Calendar.current.date(
            byAdding: .day,
            value: -AudioLibrary.RECENTLY_ADDED_DAYS_DIFFERENCE,
            to: now) ?? now
        
        for track in tracks {
            if track.date.added.value >= minimumDate {
                self.recentlyAdded.append(track)
            }
        }
    }
    
    public func getAlbums() -> [AudioAlbum] {
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
    
    public func getAlbum(byID identifier: Int) -> AudioAlbum? {
        return getAlbums().first(where: {album in
            return album.albumID == identifier
        })
    }
    
    public func getAlbumTracks(album: AudioAlbum) -> [AudioTrack] {
        let allTracks = MPMediaQuery.songs()
        
        let predicate = MPMediaPropertyPredicate.init(value: album.albumID, forProperty: MPMediaItemPropertyAlbumPersistentID)
        
        return searchForTracks(mediaQuery: allTracks, predicate: predicate)
    }
    
    public func searchForTracks(query: String) -> [AudioTrack] {
        let allTracks = MPMediaQuery.songs()
        
        let predicate = MPMediaPropertyPredicate.init(value: query, forProperty: MPMediaItemPropertyTitle, comparisonType: .contains)
        
        return searchForTracks(mediaQuery: allTracks, predicate: predicate)
    }
    
    public func recentlyAddedTracks() -> [AudioTrack] {
        loadIfNecessary()
        
        var hasLoadedRecentlyAdded = false
        
        lockEnter()
        
        hasLoadedRecentlyAdded = self.loadedRecentlyAdded
        
        lockExit()
        
        if !hasLoadedRecentlyAdded {
            loadRecentlyAddedTracks()
        }
        
        return internalQueue.sync {
            self.recentlyAdded
        }
    }
    
    public func searchForTracks(mediaQuery: MPMediaQuery, predicate: MPMediaPropertyPredicate?, cap: Int=Int.max) -> [AudioTrack] {
        var tracks: [AudioTrack] = []
        
        if let predicate_ = predicate {
            mediaQuery.addFilterPredicate(predicate_)
        }
        
        guard let result = mediaQuery.items else
        {
            return []
        }
        
        var node = AudioTrackBuilder.start()
        
        for item in result
        {
            guard let identifier = item.value(forProperty: MPMediaItemPropertyPersistentID) as? Int else {
                continue
            }
            
            guard let path = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL else {
                continue
            }
            
            let albumId_ = item.value(forProperty: MPMediaItemPropertyAlbumPersistentID) as! NSNumber
            let albumID = albumId_.intValue
            let albumTitle = item.value(forKey: MPMediaItemPropertyAlbumTitle) as? String ?? "<Unknown>"
            let artist = item.value(forKey: MPMediaItemPropertyArtist) as? String ?? "<Unknown>"
            let albumCover = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            
            let title = item.value(forProperty: MPMediaItemPropertyTitle) as? String ?? "<Unknown>"
            let trackNum_ = item.value(forProperty: MPMediaItemPropertyAlbumTrackNumber) as? NSNumber
            let durationInSeconds_ = item.value(forProperty: MPMediaItemPropertyPlaybackDuration) as? NSNumber
            
            let lyrics = item.value(forProperty: MPMediaItemPropertyLyrics) as? String ?? ""
            let dateAdded = item.value(forProperty: MPMediaItemPropertyDateAdded) as? Date
            let dateLastPlayed = item.value(forProperty: MPMediaItemPropertyLastPlayedDate) as? Date
            let lastPlayedPosition = item.value(forProperty: MPMediaItemPropertyBookmarkTime) as? NSNumber
            
            guard let trackNum = trackNum_?.intValue else {
                continue
            }
            
            guard let durationInSeconds = durationInSeconds_?.doubleValue else {
                continue
            }
            
            node.reset()
            
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
            
            node.lyrics = lyrics
            node.dateAdded = dateAdded ?? node.dateAdded
            node.dateLastPlayed = dateLastPlayed ?? node.dateLastPlayed
            node.lastPlayedPosition = lastPlayedPosition?.doubleValue ?? 0
            
            do {
                let result = try node.build()
                tracks.append(result)
            } catch {
                
            }
            
            if tracks.count >= cap {
                break
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
