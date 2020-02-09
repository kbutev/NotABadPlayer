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
    public static let FAVORITE_TRACKS_CAP = FavoritesStorage.CAPACITY
    public static let RECENTLY_ADDED_DAYS_DIFFERENCE = 30
    public static let RECENTLY_ADDED_CAPACITY = 100
    public static let LIBRARY_CHANGES_ALERT_SEC_DELAY: Double = 5
    
    private let synchronous: DispatchQueue
    
    private var loadedAlbums : Bool = false
    private var albums : [AudioAlbum] = []
    
    private var loadedRecentlyAdded : Bool = false
    private var recentlyAdded : [AudioTrack] = []
    
    private var audioLibraryChangesListeners : [AudioLibraryChangesListenerReference] = []
    private var audioLibraryChangesUpdatePending: Bool = false
    
    private var markedFavoriteTracks: [AudioTrack] = []
    private var lastTimeFavoritesUpdated: Date?
    
    init() {
        synchronous = DispatchQueue(label: "AudioLibrary.synchronous")
        NotificationCenter.default.addObserver(self, selector: #selector(onLibraryChanges), name: .MPMediaLibraryDidChange, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    func favoriteTracks() -> [AudioTrack] {
        loadIfNecessary()
        
        let lastUpdateTime = synchronous.sync {
            return self.lastTimeFavoritesUpdated
        }
        
        let lastUpdateOfStorage = GeneralStorage.shared.favorites.lastTimeUpdated
        
        if let lastUpdate = lastUpdateTime {
            if lastUpdate > lastUpdateOfStorage {
                return synchronous.sync {
                    return self.markedFavoriteTracks
                }
            }
        }
        
        let tracks = updateFavoriteTracksIfNecessary()
        
        synchronous.sync {
            self.markedFavoriteTracks = tracks
            self.lastTimeFavoritesUpdated = lastUpdateOfStorage
        }
        
        return tracks
    }
    
    private func updateFavoriteTracksIfNecessary() -> [AudioTrack] {
        let mediaQuery: MPMediaQuery = MPMediaQuery.albums()
        
        guard let result = mediaQuery.items else
        {
            return []
        }
        
        let favoriteItems = GeneralStorage.shared.favorites.items
        
        var tracks: [AudioTrack] = []
        var items: [(AudioTrack, FavoriteStorageItem)] = []
        
        let node = AudioTrackBuilder.start()
        
        for item in result
        {
            if tracks.count >= AudioLibrary.FAVORITE_TRACKS_CAP {
                break
            }
            
            // Build tracks whose path matches the path of the favorite item
            guard let path = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL else {
                continue
            }
            
            let favoriteFirst = favoriteItems.filter { (item) -> Bool in
                return item.trackPath == path
            }.first
            
            guard let favorite = favoriteFirst else {
                continue
            }
            
            guard let track = buildTrackFromMPItem(item, reuseNode: node) else {
                continue
            }
            
            items.append((track, favorite))
        }
        
        items.sort { (a, b) -> Bool in
            return a.1.dateFavorited > b.1.dateFavorited
        }
        
        tracks = items.map({ (track, item) -> AudioTrack in
            return track
        })
        
        return tracks
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
        
        let node = AudioTrackBuilder.start()
        
        for item in result
        {
            if tracks.count >= cap {
                break
            }
            
            guard let track = buildTrackFromMPItem(item, reuseNode: node) else {
                continue
            }
            
            tracks.append(track)
        }
        
        return tracks
    }
    
    private func buildTrackFromMPItem(_ item: MPMediaItem) -> AudioTrack? {
        return buildTrackFromMPItem(item, reuseNode: AudioTrackBuilder.start())
    }
    
    private func buildTrackFromMPItem(_ item: MPMediaItem, reuseNode: BaseAudioTrackBuilderNode) -> AudioTrack? {
        var node = reuseNode
        
        guard let identifier = item.value(forProperty: MPMediaItemPropertyPersistentID) as? Int else {
            return nil
        }
        
        guard let path = item.value(forProperty: MPMediaItemPropertyAssetURL) as? URL else {
            return nil
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
            return nil
        }
        
        guard let durationInSeconds = durationInSeconds_?.doubleValue else {
            return nil
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
        
        return try? node.build()
    }
    
    // # Audio library changes listening
    
    func registerLibraryChangesListener(_ listener: AudioLibraryChangesListener) {
        synchronous.sync {
            self.audioLibraryChangesListeners.append(AudioLibraryChangesListenerReference(listener))
        }
    }
    
    func unregisterLibraryChangesListener(_ listener: AudioLibraryChangesListener) {
        synchronous.sync {
            self.audioLibraryChangesListeners.removeAll { (ref) -> Bool in
                return ref.value === listener
            }
        }
    }
    
    @objc private func onLibraryChanges() {
        requestAudioLibraryChangeUpdate()
    }
    
    private func isRequestForAudioLibraryChangeUpdatePending() -> Bool {
        return synchronous.sync {
            return self.audioLibraryChangesUpdatePending
        }
    }
    
    private func requestAudioLibraryChangeUpdate() {
        Logging.log(AudioLibrary.self, "Audio library changed in the background")
        
        // When the library changes, the event for library changes is sent many times
        // In order to prevent spam, limit the number of listener alerts to every LIBRARY_CHANGES_ALERT_SEC_DELAY
        
        var isAlreadyPending: Bool = false
        
        synchronous.sync {
            isAlreadyPending = self.audioLibraryChangesUpdatePending
            self.audioLibraryChangesUpdatePending = true
        }
        
        // Do nothing if already pending
        if isAlreadyPending {
            return
        }
        
        // Alert the listeners after a delay
        let deadline = DispatchTime.now() + AudioLibrary.LIBRARY_CHANGES_ALERT_SEC_DELAY
        
        DispatchQueue.global().asyncAfter(deadline: deadline, execute: {
            self.synchronous.sync {
                self.audioLibraryChangesUpdatePending = false
            }
            
            self.alertAllOfLibraryChanges()
        })
    }
    
    @objc private func alertAllOfLibraryChanges() {
        Logging.log(AudioLibrary.self, "Alert audio library listeners")
        
        var listenersToBeAlerted: [AudioLibraryChangesListenerReference] = []
        
        // Safely copy
        synchronous.sync {
            for listener in self.audioLibraryChangesListeners {
                listenersToBeAlerted.append(listener)
            }
        }
        
        // Alert delegates
        for listener in listenersToBeAlerted {
            listener.value?.onMediaLibraryChanged()
        }
        
        // Cleanup
        cleanup()
    }
    
    private func cleanup() {
        synchronous.sync {
            self.audioLibraryChangesListeners.removeAll { (ref) -> Bool in
                return ref.isNil
            }
        }
    }
}

protocol AudioLibraryChangesListener: AnyObject {
    func onMediaLibraryChanged()
}

struct AudioLibraryChangesListenerReference {
    public weak var value: AudioLibraryChangesListener?
    
    public var isNil: Bool {
        get {
            return self.value == nil
        }
    }
    
    init(_ value: AudioLibraryChangesListener) {
        self.value = value
    }
}
