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
    public static let SEARCH_TRACKS_CAP = 1000
    public static let RECENTLY_ADDED_DAYS_DIFFERENCE = 30
    public static let RECENTLY_ADDED_CAPACITY = 100
    
    private let synchronous: DispatchQueue
    
    private var loadedAlbums : Bool = false
    private var albums : [AudioAlbum] = []
    
    private var loadedRecentlyAdded : Bool = false
    private var recentlyAdded : [AudioTrack] = []
    
    init() {
        synchronous = DispatchQueue(label: "AudioLibrary.synchronous")
    }
    
    public func loadIfNecessary() {
        var hasLoadedAlbums = false
        
        synchronous.sync {
            hasLoadedAlbums = self.loadedAlbums
        }
        
        if !hasLoadedAlbums {
            load()
        }
    }
    
    public func load() {
        synchronous.sync {
            loadAlbums()
        }
    }
    
    private func loadAlbums() {
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
        let allTracks = MPMediaQuery.songs()
        
        let tracks: [AudioTrack] = searchForTracks(mediaQuery: allTracks, predicate: nil, cap: AudioLibrary.RECENTLY_ADDED_CAPACITY)
        
        let now = Date()
        let minimumDate = Calendar.current.date(
            byAdding: .day,
            value: -AudioLibrary.RECENTLY_ADDED_DAYS_DIFFERENCE,
            to: now) ?? now
        
        synchronous.sync {
            self.recentlyAdded.removeAll()
            
            for track in tracks {
                if track.date.added.value >= minimumDate {
                    self.recentlyAdded.append(track)
                }
            }
        }
    }
    
    public func getAlbums() -> [AudioAlbum] {
        var hasLoadedAlbums: Bool = false
        
        synchronous.sync {
            hasLoadedAlbums = self.loadedAlbums
        }
        
        if !hasLoadedAlbums
        {
            load()
        }
        
        return synchronous.sync {
            return albums
        }
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
    
    public func searchForTracks(query: String, filter: SearchTracksFilter) -> [AudioTrack] {
        if query.count == 0 {
            return []
        }
        
        let allTracks = MPMediaQuery.songs()
        
        var property: String = MPMediaItemPropertyTitle
        
        switch filter {
        case .Title:
            property = MPMediaItemPropertyTitle
        case .Album:
            property = MPMediaItemPropertyAlbumTitle
        case .Artist:
            property = MPMediaItemPropertyArtist
        }
        
        let predicate = MPMediaPropertyPredicate.init(value: query, forProperty: property, comparisonType: .contains)
        
        return searchForTracks(mediaQuery: allTracks, predicate: predicate)
    }
    
    public func recentlyAddedTracks() -> [AudioTrack] {
        loadIfNecessary()
        
        var hasLoadedRecentlyAdded = false
        
        synchronous.sync {
            hasLoadedRecentlyAdded = self.loadedRecentlyAdded
        }
        
        if !hasLoadedRecentlyAdded {
            loadRecentlyAddedTracks()
        }
        
        return synchronous.sync {
            self.recentlyAdded
        }
    }
    
    public func searchForTracks(mediaQuery: MPMediaQuery, predicate: MPMediaPropertyPredicate?) -> [AudioTrack] {
        return searchForTracks(mediaQuery: mediaQuery, predicate: predicate, cap: AudioLibrary.SEARCH_TRACKS_CAP)
    }
    
    public func searchForTracks(mediaQuery: MPMediaQuery, predicate: MPMediaPropertyPredicate?, cap: Int) -> [AudioTrack] {
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
}
