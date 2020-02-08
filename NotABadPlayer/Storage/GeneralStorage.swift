//
//  GeneralStorage.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

// Provides simple interface to the user defaults (built in storage).
// Before using the general storage, you MUST call initialize().
class GeneralStorage {
    public static let shared = GeneralStorage()
    
    public static let CURRENT_VERSION = "1.1"
    
    public let favorites: FavoritesStorage
    
    private var _storage: UserDefaults?
    
    private var storage: UserDefaults {
        get {
            checkIfStorageIsInitialized()
            
            return self._storage!
        }
    }
    
    private (set) var isFirstTimeLaunch = true
    
    private var keybinds: [String: String] = [:]
    
    private var observers: [GeneralStorageObserverValue] = []
    
    init() {
        self.favorites = FavoritesStorage()
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
            Logging.log(GeneralStorage.self, "First time launching the program!")
            
            storage.set(true, forKey: "notFirstTime")
            
            resetDefaultSettingsValues()
        }
    }
    
    private func detectVersionChange() {
        var storageVersion = getStorageVersion()
        let currentVersion = GeneralStorage.CURRENT_VERSION
        
        saveStorageVersion(currentVersion)
        
        guard storageVersion == currentVersion else
        {
            return
        }
        
        // Migrate to 1.0
        if storageVersion == ""
        {
            let version = "1.0"
            
            Logging.log(GeneralStorage.self, "Migrating settings from version nil to version \(version)")
            
            storageVersion = version
        }
        
        // Migrate to 1.1
        if storageVersion == "1.0"
        {
            let version = "1.1"
            
            Logging.log(GeneralStorage.self, "Migrating settings from version \(storageVersion) to version \(version)")
            
            clearUserPlaylists()
            clearPlayerPlayHistoryState()
            
            storageVersion = version
        }
        
        Logging.log(GeneralStorage.self, "Successfully migrated settings values!")
    }
    
    func resetDefaultSettingsValues() {
        Logging.log(GeneralStorage.self, "Resetting settings values to their defaults")
        
        savePlayerPlayedHistoryCapacity(50)
        saveAppThemeValue(.LIGHT)
        saveTrackSortingValue(.TRACK_NUMBER)
        saveShowVolumeBarValue(.NO)
        saveOpenPlayerOnPlayValue(.NO)
        saveCachingPolicy(.ALBUMS_ONLY)
        
        saveKeybindAction(action: .PAUSE_OR_RESUME, forInput: .PLAYER_PLAY_BUTTON)
        saveKeybindAction(action: .RECALL, forInput: .PLAYER_RECALL)
        saveKeybindAction(action: .NEXT, forInput: .PLAYER_NEXT_BUTTON)
        saveKeybindAction(action: .PREVIOUS, forInput: .PLAYER_PREVIOUS_BUTTON)
        saveKeybindAction(action: .PREVIOUS, forInput: .PLAYER_SWIPE_LEFT)
        saveKeybindAction(action: .NEXT, forInput: .PLAYER_SWIPE_RIGHT)
        saveKeybindAction(action: .PAUSE_OR_RESUME, forInput: .QUICK_PLAYER_PLAY_BUTTON)
        saveKeybindAction(action: .FORWARDS_8, forInput: .QUICK_PLAYER_NEXT_BUTTON)
        saveKeybindAction(action: .BACKWARDS_8, forInput: .QUICK_PLAYER_PREVIOUS_BUTTON)
        saveKeybindAction(action: .FORWARDS_8, forInput: .LOCK_PLAYER_NEXT_BUTTON)
        saveKeybindAction(action: .BACKWARDS_8, forInput: .LOCK_PLAYER_PREVIOUS_BUTTON)
        saveKeybindAction(action: .PAUSE, forInput: .EARPHONES_UNPLUG)
        
        saveCachingPolicy(.ALBUMS_ONLY);
        
        let playlists: [MutableAudioPlaylist] = []
        
        storage.set(playlists, forKey: "user_playlists")
        
        // Observers alert
        onResetDefaultSettings()
    }
    
    private func saveStorageVersion(_ version: String) {
        storage.set(version, forKey: "storage_version")
    }
    
    private func getStorageVersion() -> String {
        return storage.string(forKey: "storage_version") ?? ""
    }
    
    func savePlayerState() {
        let player = AudioPlayer.shared
        var playlistToSerialize: MutableAudioPlaylist?
        
        if let playPlaylist = player.playlist
        {
            do {
                playlistToSerialize = try AudioPlaylistBuilder.buildMutableFromImmutable(prototype: playPlaylist)
            } catch {
                
            }
        }
        
        if let playlistSerialized = Serializing.jsonSerialize(object: playlistToSerialize)
        {
            storage.set(player.playOrder.rawValue, forKey: "player_play_order")
            storage.set(playlistSerialized, forKey: "player_current_playlist")
            storage.set(player.currentPositionSec, forKey: "player_current_position")
            
            Logging.log(GeneralStorage.self, "Saved audio player state to storage.")
        }
        else
        {
            storage.set(AudioPlayOrder.FORWARDS.rawValue, forKey: "player_play_order")
            storage.set("", forKey: "player_current_playlist")
            storage.set(0, forKey: "player_current_position")
            
            Logging.log(GeneralStorage.self, "Failed to save audio player state to storage.")
        }
    }
    
    func restorePlayerState() {
        let player = AudioPlayer.shared
        
        guard let playOrderAsString = storage.string(forKey: "player_play_order") else {
            return
        }
        
        guard let playlistAsString = storage.string(forKey: "player_current_playlist") else {
            return
        }
        
        Logging.log(GeneralStorage.self, "Restoring audio player state...")
        
        guard let playOrder: AudioPlayOrder = AudioPlayOrder(rawValue: playOrderAsString) else {
            Logging.log(GeneralStorage.self, "Error: could not restore player audio state")
            return
        }
        
        var playlistObject: MutableAudioPlaylist?
        
        do {
            playlistObject = try AudioPlaylistBuilder.buildLatestMutableVersionFrom(serializedData: playlistAsString)
        } catch {
            
        }
        
        guard let playlist = playlistObject else {
            Logging.log(GeneralStorage.self, "Error: could not restore player audio state")
            return
        }
        
        do {
            try player.play(playlist: playlist)
        } catch let error {
            Logging.log(GeneralStorage.self, "Error: could not restore player audio state, \(error.localizedDescription)")
            return
        }
        
        player.playOrder = playOrder
        
        let currentPositionSec = storage.double(forKey: "player_current_position")
        
        player.seekTo(seconds: currentPositionSec)
        
        // Always pause by default when restoring state from storage
        player.pause()
        
        // Success
        Logging.log(GeneralStorage.self, "Successfully restored the audio player state!")
    }
    
    func savePlayerPlayHistoryState() {
        if let playHistory = Serializing.jsonSerialize(object: AudioPlayer.shared.playerHistory.playHistory)
        {
            storage.set(playHistory, forKey: "play_history")
        }
    }
    
    func restorePlayerPlayHistoryState() {
        if let value = storage.string(forKey: "play_history")
        {
            do {
                let result:[AudioTrack] = try AudioTrackBuilder.buildLatestVersionListFrom(serializedData: value)
                AudioPlayer.shared.playerHistory.setPlayHistory(result)
                return
            } catch {
                Logging.log(GeneralStorage.self, "Error: could not restore play history for the player from storage")
            }
        }
    }
    
    func clearPlayerPlayHistoryState() {
        storage.set(nil, forKey: "play_history")
    }
    
    func saveSearchQuery(_ searchQuery: String) {
        storage.set(searchQuery, forKey: "search_query")
    }
    
    func retrieveSearchQuery() -> String {
        return storage.string(forKey: "search_query") ?? ""
    }
    
    func saveSearchQueryFilter(_ searchQueryFilter: SearchTracksFilter) {
        storage.set(searchQueryFilter.rawValue, forKey: "search_query_filter")
    }
    
    func retrieveSearchQueryFilter() -> SearchTracksFilter {
        if let value = storage.string(forKey: "search_query_filter")
        {
            if let result = SearchTracksFilter(rawValue: value)
            {
                return result
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read SearchTracksFilter value from storage")
        }
        
        return .Title
    }
    
    func getKeybindAction(forInput input: ApplicationInput) -> ApplicationAction {
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
    
    func saveKeybindAction(action: ApplicationAction, forInput input: ApplicationInput) {
        storage.set(action.rawValue, forKey: input.rawValue)
        
        onKeybindChange(forInput: input)
    }
    
    func getPlayerPlayedHistoryCapacity() -> UInt {
        return UInt(storage.integer(forKey: "play_history_capacity"))
    }
    
    func savePlayerPlayedHistoryCapacity(_ capacity: UInt) {
        storage.set(capacity, forKey: "play_history_capacity")
    }
    
    func getUserPlaylists() -> [MutableAudioPlaylist] {
        if let value = storage.string(forKey: "user_playlists")
        {
            do {
                return try AudioPlaylistBuilder.buildLatestMutableVersionListFrom(serializedData: value)
            } catch {
                
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read the user playlists from storage")
        }
        
        return []
    }
    
    func saveUserPlaylists(_ playlists: [MutableAudioPlaylist]) {
        if let serialized = Serializing.jsonSerialize(object: playlists)
        {
            storage.set(serialized, forKey: "user_playlists")
        }
    }
    
    func clearUserPlaylists() {
        storage.set(nil, forKey: "user_playlists")
    }
    
    func getAppThemeValue() -> AppThemeValue {
        if let value = storage.string(forKey: "app_theme")
        {
            if let result = AppThemeValue(rawValue: value)
            {
                return result
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read AppTheme value from storage")
        }
        
        return .LIGHT
    }
    
    func saveAppThemeValue(_ theme: AppThemeValue) {
        storage.set(theme.rawValue, forKey: "app_theme")
        
        // Observers alert
        onAppAppearanceChange()
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
        
        // Observers alert
        onAppAppearanceChange()
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
    
    func saveShowVolumeBarValue(_ value: ShowVolumeBar) {
        storage.set(value.rawValue, forKey: "show_volume_bar")
        
        // Observers alert
        onAppAppearanceChange()
    }
    
    func getOpenPlayerOnPlayValue() -> OpenPlayerOnPlay {
        if let value = storage.string(forKey: "open_player_on_play")
        {
            if let result = OpenPlayerOnPlay(rawValue: value)
            {
                return result
            }
            
            Logging.log(GeneralStorage.self, "Error: could not read OpenPlayerOnPlay value from storage")
        }
        
        return .NO
    }
    
    func saveOpenPlayerOnPlayValue(_ value: OpenPlayerOnPlay) {
        storage.set(value.rawValue, forKey: "open_player_on_play")
    }
    
    func saveCachingPolicy(_ value: TabsCachingPolicy) {
        storage.set(value.rawValue, forKey: "caching_policy")
        
        // Observers alert
        onTabCachingPolicyChange(value)
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
    
    func numberOfLyricsTapped() -> UInt {
        return UInt(storage.integer(forKey: "number_times_lyrics_tapped"))
    }
    
    func incrementNumberOfLyricsTapped() {
        let count = numberOfLyricsTapped() + 1
        
        storage.set(count, forKey: "number_times_lyrics_tapped")
    }
}

// Utils
extension GeneralStorage {
    private func checkIfStorageIsInitialized() {
        if self._storage == nil
        {
            fatalError("[\(String(describing: GeneralStorage.self))] being used before being initialized, initialize() has never been called")
        }
    }
}

// Component - Observers
extension GeneralStorage {
    func attach(observer: GeneralStorageObserver) {
        if observers.contains(where: {(element) -> Bool in element.value === observer})
        {
            return
        }
        
        observers.append(GeneralStorageObserverValue(observer))
    }
    
    func detach(observer: GeneralStorageObserver) {
        observers.removeAll(where: {(element) -> Bool in element.value === observer})
    }
    
    private func onAppAppearanceChange() {
        for observer in observers
        {
            observer.observer?.onAppAppearanceChange()
        }
    }
    
    private func onTabCachingPolicyChange(_ value: TabsCachingPolicy) {
        for observer in observers
        {
            observer.observer?.onTabCachingPolicyChange(value)
        }
    }
    
    private func onKeybindChange(forInput input: ApplicationInput) {
        for observer in observers
        {
            observer.observer?.onKeybindChange(forInput: input)
        }
    }
    
    private func onResetDefaultSettings() {
        for observer in observers
        {
            observer.observer?.onResetDefaultSettings()
        }
    }
}
