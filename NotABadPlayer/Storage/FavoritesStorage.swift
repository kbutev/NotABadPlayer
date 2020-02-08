//
//  FavoritesStorage.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import Foundation

class FavoritesStorage {
    public let FAVORITES_STORAGE_KEY = "FavoritesStorage.data.key"
    
    private let synchronous = DispatchQueue(label: "FavoritesStorage.synchronous")
    
    private var storage: UserDefaults
    
    private var _favoritesLoaded = false
    private var _favorites: [FavoriteStorageItem] = []
    
    init(storage: UserDefaults=UserDefaults.standard) {
        self.storage = storage
    }
    
    func isMarkedFavorite(_ track: AudioTrack) -> Bool {
        return markedFavoriteItem(for: track) != nil
    }
    
    func markedFavoriteItem(for track: AudioTrack) -> FavoriteStorageItem? {
        updateLocalStorageIfNecessary()
        
        let item = FavoriteStorageItem(track)
        
        return synchronous.sync {
            _favorites.filter({ (element) -> Bool in
                return element == item
            }).first
        }
    }
    
    @discardableResult
    func markFavorite(track: AudioTrack) -> FavoriteStorageItem {
        if let already = markedFavoriteItem(for: track) {
            return already
        }
        
        updateLocalStorageIfNecessary()
        
        let item = FavoriteStorageItem(track)
        
        synchronous.sync {
            _favorites.append(item)
        }
        
        saveLocalStorage()
        
        return item
    }
    
    func unmarkFavorite(track: AudioTrack) {
        if markedFavoriteItem(for: track) == nil {
            return
        }
        
        updateLocalStorageIfNecessary()
        
        let item = FavoriteStorageItem(track)
        
        synchronous.sync {
            _favorites.removeAll(where: { (element) -> Bool in
                return element == item
            })
        }
        
        saveLocalStorage()
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
    
    init(_ track: AudioTrack, dateFavorited: Date=Date()) {
        self.identifier = "\(track.albumTitle).\(track.title).\(track.duration)"
        self.dateFavorited = dateFavorited
    }
    
    static func ==(_ a: FavoriteStorageItem, _ b: FavoriteStorageItem) -> Bool {
        return a.identifier == b.identifier
    }
}
