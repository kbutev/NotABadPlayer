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
        return false
    }
    
    func markedFavoriteItem(for track: AudioTrack) -> FavoriteStorageItem? {
        return nil
    }
    
    @discardableResult
    func markFavorite(track: AudioTrack) -> FavoriteStorageItem {
        if let already = markedFavoriteItem(for: track) {
            return already
        }
        
        let item = FavoriteStorageItem(track.identifier)
        
        return item
    }
    
    func unmarkFavorite(track: AudioTrack) {
        let item = FavoriteStorageItem(track.identifier)
        
        
    }
    
    private func updateLocalStorageIfNecessary() {
        let update = synchronous.sync {
            return _favoritesLoaded
        }
        
        if update {
            updateLocalStorage()
        }
    }
    
    private func updateLocalStorage() {
        synchronous.sync {
            _favoritesLoaded = true
            
            guard let data = storage.data(forKey: FAVORITES_STORAGE_KEY) else {
                return
            }
            
            guard let favorites: [FavoriteStorageItem] = Serializing.deserialize(fromData: data) else {
                return
            }
            
            _favorites = favorites
        }
    }
}

struct FavoriteStorageItem: Codable {
    let identifier: String
    let dateFavorited: Date
    
    init(_ identifier: String, dateFavorited: Date=Date()) {
        self.identifier = identifier
        self.dateFavorited = dateFavorited
    }
    
    init(_ identifier: Int, dateFavorited: Date=Date()) {
        self.identifier = "\(identifier)"
        self.dateFavorited = dateFavorited
    }
}
