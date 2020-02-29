//
//  Strings.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 19.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

enum Text: String {
    public static let ARG_PLACEHOLDER = "@!"
    
    static func localizedText(_ string: String) -> String {
        return string
    }
    
    static func value(_ value: Text) -> String {
        return localizedText(value.rawValue)
    }
    
    static func value(_ value: Text, _ arg1: String) -> String {
        return localizedText(value.rawValue).stringByReplacingFirstOccurrenceOfString(target: Text.ARG_PLACEHOLDER, replaceString: arg1)
    }
    
    static func value(_ value: Text, _ arg1: String, _ arg2: String) -> String {
        var string = localizedText(value.rawValue)
        
        string = string.stringByReplacingFirstOccurrenceOfString(target: Text.ARG_PLACEHOLDER, replaceString: arg1)
        string = string.stringByReplacingFirstOccurrenceOfString(target: Text.ARG_PLACEHOLDER, replaceString: arg2)
        
        return string
    }
    
    // List of text values
    case Empty = ""
    case ListDescription = "@! tracks, duration @!"
    case NothingPlaying = "Nothing Playing"
    case ZeroTimer = "0:00"
    case DoubleZeroTimers = "0:00/0:00"
    
    case AlbumsLibraryChanged = "Device library changed"
    
    case ListsDeleteButtonName = "Delete"
    case ListsDoneButtonName = "Done"
    case PlaylistRecentlyPlayed = "Recently Played"
    case PlaylistRecentlyAdded = "Recently Added"
    case PlaylistFavorites = "Favorites"
    case PlaylistCellDescription = "@! tracks"
    
    case PlayerLyricsNotAvailable = "No lyrics"
    
    case SearchDescriptionNoResults = "no results"
    case SearchDescriptionResults = "@! search results"
    case SearchPlaylistName = "Search Results"
    
    case SettingsTheme = "Theme"
    case SettingsTrackSorting = "Track Sorting"
    case SettingsShowVolumeBar = "Show Volume Bar"
    case SettingsPlayOpensPlayer = "Play Opens Player"
    case SettingsPlayerVolumeUp = "Player Volume D"
    case SettingsPlayerVolumeDown = "Player Volume U"
    case SettingsPlayerVolume = "Player Speaker"
    case SettingsPlayerRecall = "Player Recall"
    case SettingsPlayerPrevious = "Player Previous"
    case SettingsPlayerNext = "Player Next"
    case SettingsPlayerSwipeL = "Player Swipe L"
    case SettingsPlayerSwipeR = "Player Swipe R"
    case SettingsQPlayerVolumeU = "QPlayer Volume U"
    case SettingsQPlayerVolumeD = "QPlayer Volume D"
    case SettingsQPlayerPrevious = "QPlayer Previous"
    case SettingsQPlayerNext = "QPlayer Next"
    case SettingsLockPlayerPrevious = "LPlayer Previous"
    case SettingsLockPlayerNext = "LPlayer Next"
    case SettingsAbout = "Version 1.1 (2)\nReleased 2019.12.7\nProgrammed, designed & tested by Kristiyan Butev"
    
    case Error = "Error"
    case ErrorUnknown = "Unknown error occured"
    case ErrorAlbumDoesNotExist = "Album does not exist"
    case ErrorPlaylistNameEmpty = "Playlist name cannot be empty"
    case ErrorPlaylistEmpty = "Playlist must have at least 1 track"
    case ErrorPlaylistAlreadyExists = "A playlist with that name already exists"
}
