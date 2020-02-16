//
//  FavoritesStorage.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import Foundation

enum FavoritesStorageError: Error {
    case outOfCapacity
}

class FavoritesStorage {
    public static let CAPACITY = 1000
    public let FAVORITES_STORAGE_KEY = "FavoritesStorage.data.key"
    
    public var items: [FavoriteStorageItem] {
        get {
            updateLocalStorageIfNecessary()
            
            return synchronous.sync {
                return _favorites
            }
        }
    }
    
    public var lastTimeUpdated: Date {
        get {
            updateLocalStorageIfNecessary()
            
            return synchronous.sync {
                return _lastTimeUpdated
            }
        }
    }
    
    private let synchronous = DispatchQueue(label: "FavoritesStorage.synchronous")
    
    private var storage: UserDefaults
    
    private var _favoritesLoaded = false
    private var _favorites: [FavoriteStorageItem] = []
    
    private var _lastTimeUpdated = Date()
    
    init(storage: UserDefaults=UserDefaults.standard) {
        self.storage = storage
    }
    
    func isMarkedFavorite(_ track: BaseAudioTrack) -> Bool {
        return markedFavoriteItem(for: track) != nil
    }
    
    func markedFavoriteItem(for track: BaseAudioTrack) -> FavoriteStorageItem? {
        updateLocalStorageIfNecessary()
        
        let item = FavoriteStorageItem(track)
        
        return synchronous.sync {
            _favorites.filter({ (element) -> Bool in
                return element == item
            }).first
        }
    }
    
    @discardableResult
    func markFavoriteForced(track: BaseAudioTrack) -> FavoriteStorageItem {
        return try! markFavorite(track: track, forced: true)
    }
    
    @discardableResult
    func markFavorite(track: BaseAudioTrack) throws -> FavoriteStorageItem {
        return try markFavorite(track: track, forced: false)
    }
    
    @discardableResult
    func markFavorite(track: BaseAudioTrack, forced: Bool) throws -> FavoriteStorageItem {
        updateLocalStorageIfNecessary()
        
        if let already = markedFavoriteItem(for: track) {
            return already
        }
        
        let item = FavoriteStorageItem(track)
        
        try synchronous.sync {
            if _favorites.count > FavoritesStorage.CAPACITY {
                // Make sure the capacity is not exceeded
                if !forced {
                    throw FavoritesStorageError.outOfCapacity
                }
                
                let _ = _favorites.popLast()
            }
            
            _favorites.insert(item, at: 0)
            
            _lastTimeUpdated = Date()
        }
        
        saveLocalStorage()
        
        return item
    }
    
    func unmarkFavorite(track: BaseAudioTrack) {
        updateLocalStorageIfNecessary()
        
        guard let item = markedFavoriteItem(for: track) else {
            return
        }
        
        synchronous.sync {
            _favorites.removeAll(where: { (element) -> Bool in
                return element == item
            })
            
            _lastTimeUpdated = Date()
        }
        
        saveLocalStorage()
    }
    
    func unmarkOldestFavorite() {
        updateLocalStorageIfNecessary()
        
        synchronous.sync {
            if !_favorites.isEmpty {
                let _ = _favorites.popLast()
            }
        }
    }
    
    private func updateLocalStorageIfNecessary() {
        let update = synchronous.sync {
            return !_favoritesLoaded
        }
        
        if update {
            updateLocalStorage()
        }
    }
    
    private func updateLocalStorage() {
        synchronous.sync {
            _favoritesLoaded = true
            
            guard let data = storage.string(forKey: FAVORITES_STORAGE_KEY) else {
                return
            }
            
            guard let favorites: [FavoriteStorageItem] = Serializing.jsonDeserialize(fromString: data) else {
                Logging.warning(FavoritesStorage.self, "Failed to unarchive favorite items from storage")
                return
            }
            
            Logging.log(FavoritesStorage.self, "Retrieved \(favorites.count) favorite items from storage")
            
            _favorites = favorites
            
            _lastTimeUpdated = Date()
        }
    }
    
    private func saveLocalStorage() {
        updateLocalStorageIfNecessary()
        
        synchronous.sync {
            guard let data = Serializing.jsonSerialize(object: _favorites) else {
                Logging.warning(FavoritesStorage.self, "Failed to archive favorite items to storage")
                return
            }
            
            storage.set(data, forKey: FAVORITES_STORAGE_KEY)
        }
    }
}

struct FavoriteStorageItem: Codable, Equatable {
    let identifier: String
    let dateFavorited: Date
    let trackPath: URL
    
    init(_ track: BaseAudioTrack, dateFavorited: Date=Date()) {
        self.trackPath = track.filePath
        self.identifier = trackPath.absoluteString
        self.dateFavorited = dateFavorited
    }
    
    static func ==(_ a: FavoriteStorageItem, _ b: FavoriteStorageItem) -> Bool {
        if a.identifier.isEmpty {
            return false
        }
        
        return a.identifier == b.identifier
    }
}
