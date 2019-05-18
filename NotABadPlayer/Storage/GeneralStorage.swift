//
//  GeneralStorage.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class GeneralStorage {
    public static let shared = GeneralStorage()
    
    public static let CURRENT_VERSION = "1.0"
    
    private var _storage: UserDefaults?
    
    private var storage: UserDefaults {
        get {
            checkIfStorageIsInitialized()
            
            return self._storage!
        }
    }
    
    private (set) var isFirstTimeLaunch = true
    
    private var keybinds: [String: String] = [:]
    
    init() {
        
    }
    
    func initialize(storage: UserDefaults=UserDefaults.standard) {
        self._storage = storage
        
        detectFirstTimeLaunch()
        
        detectVersionChange()
    }
    
    private func detectFirstTimeLaunch() {
        isFirstTimeLaunch = !storage.bool(forKey: "notFirstTime")
        
        if (isFirstTimeLaunch)
        {
            Logging.log(GeneralStorage.self, "First time launching the program! Setting app settings to their default values")
            
            storage.set(true, forKey: "notFirstTime")
            
            resetDefaultSettingsValues()
        }
    }
    
    private func detectVersionChange() {
        let storageVersion = getStorageVersion()
        let currentVersion = GeneralStorage.CURRENT_VERSION
        
        saveStorageVersion(currentVersion)
        
        if storageVersion != currentVersion
        {
            if storageVersion == ""
            {
                Logging.log(GeneralStorage.self, "Migrating settings from version nil to version \(storageVersion)")
                
                Logging.log(GeneralStorage.self, "Successfully migrated settings values!")
                return
            }
        }
    }
    
    func resetDefaultSettingsValues() {
        savePlayerPlayedHistoryCapacity(50)
        saveAppThemeValue(AppTheme.LIGHT)
        saveAlbumSortingValue(AlbumSorting.TITLE)
        saveTrackSortingValue(TrackSorting.TRACK_NUMBER)
        saveShowStarsValue(ShowStars.NO)
        saveShowVolumeBarValue(ShowVolumeBar.NO)
        
        saveSettingsAction(action: .VOLUME_UP, forInput: .PLAYER_VOLUME_UP_BUTTON)
        saveSettingsAction(action: .VOLUME_DOWN, forInput: .PLAYER_VOLUME_DOWN_BUTTON)
        saveSettingsAction(action: .PAUSE_OR_RESUME, forInput: .PLAYER_PLAY_BUTTON)
        saveSettingsAction(action: .RECALL, forInput: .PLAYER_RECALL)
        saveSettingsAction(action: .NEXT, forInput: .PLAYER_NEXT_BUTTON)
        saveSettingsAction(action: .PREVIOUS, forInput: .PLAYER_PREVIOUS_BUTTON)
        saveSettingsAction(action: .PREVIOUS, forInput: .PLAYER_SWIPE_LEFT)
        saveSettingsAction(action: .NEXT, forInput: .PLAYER_SWIPE_RIGHT)
        saveSettingsAction(action: .VOLUME_UP, forInput: .QUICK_PLAYER_VOLUME_UP_BUTTON)
        saveSettingsAction(action: .VOLUME_DOWN, forInput: .QUICK_PLAYER_VOLUME_DOWN_BUTTON)
        saveSettingsAction(action: .PAUSE_OR_RESUME, forInput: .QUICK_PLAYER_PLAY_BUTTON)
        saveSettingsAction(action: .FORWARDS_15, forInput: .QUICK_PLAYER_NEXT_BUTTON)
        saveSettingsAction(action: .BACKWARDS_15, forInput: .QUICK_PLAYER_PREVIOUS_BUTTON)
        saveSettingsAction(action: .PAUSE, forInput: .EARPHONES_UNPLUG)
        
        saveCachingPolicy(.ALBUMS_ONLY);
    }
    
    private func saveStorageVersion(_ version: String) {
        storage.set(version, forKey: "storage_version")
    }
    
    private func getStorageVersion() -> String {
        return storage.string(forKey: "storage_version") ?? ""
    }
    
    func savePlayerState() {
        let player = AudioPlayer.shared
        
        guard let playlist = player.playlist else {
            return
        }
        
        let playlistSerialized = Serializing.serialize(object: playlist)
        
        storage.set(playlistSerialized, forKey: "player_current_playlist")
        storage.set(player.currentPositionMSec, forKey: "player_current_position")
    }
    
    func restorePlayerState() {
        let player = AudioPlayer.shared
        
        guard let playlistAsString = storage.string(forKey: "player_current_playlist") else {
            return
        }
        
        guard let playlist:AudioPlaylist = Serializing.deserialize(fromData: playlistAsString) else {
            return
        }
        
        do {
            try player.play(playlist: playlist)
        } catch let error {
            Logging.log(GeneralStorage.self, "Error: could not restore player audio state, \(error.localizedDescription)")
            return
        }
        
        player.setPlaylistPlayOrder(playlist.playOrder)
        
        let currentPositionMSec = storage.integer(forKey: "player_current_position")
        
        player.seekTo(mseconds: currentPositionMSec)
        
        // Always pause by default when restoring state from storage
        player.pause()
    }
    
    func savePlayerPlayHistoryState() {
        if let playHistory = Serializing.serialize(object: AudioPlayer.shared.playHistory)
        {
            storage.set(playHistory, forKey: "play_history")
        }
    }
    
    func restorePlayerPlayHistoryState() {
        if let value = storage.string(forKey: "play_history")
        {
            if let result:[AudioTrack] = Serializing.deserialize(fromData: value)
            {
                AudioPlayer.shared.setPlayHistory(result)
                return
            }
        }
        
        Logging.log(GeneralStorage.self, "Error: could not restore play history for the player from storage")
    }
    
    func saveSearchQuery(_ searchQuery: String) {
        storage.set(searchQuery, forKey: "search_query")
    }
    
    func retrieveSearchQuery() -> String {
        return storage.string(forKey: "search_query") ?? ""
    }
    
    func getSettingsAction(forInput input: ApplicationInput) -> ApplicationAction {
        if let value = storage.string(forKey: input.rawValue)
        {
            if let result = ApplicationAction(rawValue: value)
            {
                return result
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read ApplicationAction for input \(input.rawValue) value from storage")
        }
        
        return .DO_NOTHING
    }
    
    func saveSettingsAction(action: ApplicationAction, forInput input: ApplicationInput) {
        storage.set(action.rawValue, forKey: input.rawValue)
    }
    
    func getPlayerPlayedHistoryCapacity() -> UInt {
        return UInt(storage.integer(forKey: "play_history_capacity"))
    }
    
    func savePlayerPlayedHistoryCapacity(_ capacity: UInt) {
        storage.set(capacity, forKey: "play_history_capacity")
    }
    
    func getUserPlaylists() -> [AudioPlaylist] {
        if let value = storage.string(forKey: "user_playlists")
        {
            if let result:[AudioPlaylist] = Serializing.deserialize(fromData: value)
            {
                return result
            }
        }
        
        Logging.log(GeneralStorage.self, "Error: could not read the user playlists from storage")
        
        return []
    }
    
    func saveUserPlaylists(_ playlists: [AudioPlaylist]) {
        if let serialized = Serializing.serialize(object: playlists)
        {
            storage.set(serialized, forKey: "user_playlists")
        }
    }
    
    func getAppThemeValue() -> AppTheme {
        if let value = storage.string(forKey: "app_theme")
        {
            if let result = AppTheme(rawValue: value)
            {
                return result
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read AppTheme value from storage")
        }
        
        return .LIGHT
    }
    
    func saveAppThemeValue(_ theme: AppTheme) {
        storage.set(theme.rawValue, forKey: "app_theme")
    }
    
    func getAlbumSortingValue() -> AlbumSorting {
        if let value = storage.string(forKey: "album_sorting")
        {
            if let result = AlbumSorting(rawValue: value)
            {
                return result
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read AlbumSorting value from storage")
        }
        
        return .TITLE
    }
    
    func saveAlbumSortingValue(_ sorting: AlbumSorting) {
        storage.set(sorting.rawValue, forKey: "album_sorting")
    }
    
    func getTrackSortingValue() -> TrackSorting {
        if let value = storage.string(forKey: "track_sorting")
        {
            if let result = TrackSorting(rawValue: value)
            {
                return result
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read TrackSorting value from storage")
        }
        
        return .TITLE
    }
    
    func saveTrackSortingValue(_ sorting: TrackSorting) {
        storage.set(sorting.rawValue, forKey: "track_sorting")
    }
    
    func getShowStarsValue() -> ShowStars {
        if let value = storage.string(forKey: "show_stars")
        {
            if let result = ShowStars(rawValue: value)
            {
                return result
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read ShowStars value from storage")
        }
        
        return .NO
    }
    
    func saveShowStarsValue(_ value: ShowStars) {
        storage.set(value.rawValue, forKey: "show_stars")
    }
    
    func getShowVolumeBarValue() -> ShowVolumeBar {
        if let value = storage.string(forKey: "show_volume_bar")
        {
            if let result = ShowVolumeBar(rawValue: value)
            {
                return result
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read ShowVolumeBar value from storage")
        }
        
        return .NO
    }
    
    func saveShowVolumeBarValue(_ theme: ShowVolumeBar) {
        storage.set(theme.rawValue, forKey: "show_volume_bar")
    }
    
    func saveCachingPolicy(_ value: TabsCachingPolicy) {
        storage.set(value.rawValue, forKey: "caching_policy")
    }
    
    func getCachingPolicy() -> TabsCachingPolicy {
        if let value = storage.string(forKey: "caching_policy")
        {
            if let result = TabsCachingPolicy(rawValue: value)
            {
                return result
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read TabsCachingPolicy value from storage")
        }
        
        return .NO_CACHING
    }
    
    private func checkIfStorageIsInitialized() {
        if self._storage == nil
        {
            fatalError("[\(String(describing: GeneralStorage.self))] being used before being initialized, initialize() has never been called")
        }
    }
}
