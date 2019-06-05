//
//  AppSettings.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

enum TabID: String, CaseIterable {
    case None;
    case Albums;
    case Lists;
    case Search;
    case Settings;
    
    static func stringValues() -> [String] {
        var strings: [String] = []
        
        for value in TabID.allCases
        {
            strings.append(value.rawValue)
        }
        
        return strings
    }
}

enum AppThemeValue: String, CaseIterable {
    case LIGHT;
    case DARK;
    case MIX;
    
    static func stringValues() -> [String] {
        var strings: [String] = []
        
        for value in AppThemeValue.allCases
        {
            strings.append(value.rawValue)
        }
        
        return strings
    }
}

enum AlbumSorting: String, CaseIterable {
    case TITLE;
    
    static func stringValues() -> [String] {
        var strings: [String] = []
        
        for value in AlbumSorting.allCases
        {
            strings.append(value.rawValue)
        }
        
        return strings
    }
}

enum TrackSorting: String, CaseIterable {
    case TRACK_NUMBER;
    case TITLE;
    case LONGEST;
    case SHORTEST;
    
    static func stringValues() -> [String] {
        var strings: [String] = []
        
        for value in TrackSorting.allCases
        {
            strings.append(value.rawValue)
        }
        
        return strings
    }
}

enum ShowVolumeBar: String, CaseIterable {
    case NO;
    case LEFT_SIDE;
    case RIGHT_SIDE;
    
    static func stringValues() -> [String] {
        var strings: [String] = []
        
        for value in ShowVolumeBar.allCases
        {
            strings.append(value.rawValue)
        }
        
        return strings
    }
}

enum OpenPlayerOnPlay: String, CaseIterable {
    case NO;
    case YES;
    case PLAYLIST_ONLY;
    case SEARCH_ONLY;
    
    static func stringValues() -> [String] {
        var strings: [String] = []
        
        for value in OpenPlayerOnPlay.allCases
        {
            strings.append(value.rawValue)
        }
        
        return strings
    }
    
    func openForPlaylist() -> Bool {
        return self == .YES || self == .PLAYLIST_ONLY
    }
    
    func openForSearch() -> Bool {
        return self == .YES || self == .SEARCH_ONLY
    }
}

enum TabsCachingPolicy: String, CaseIterable {
    case NO_CACHING;
    case ALBUMS_ONLY;
    case CACHE_ALL;
    
    func canCacheAlbums() -> Bool {
        return self == .CACHE_ALL || self == .ALBUMS_ONLY
    }
    
    func canCacheLists() -> Bool {
        return self == .CACHE_ALL
    }
    
    func canCacheSearch() -> Bool {
        return self == .CACHE_ALL
    }
    
    func canCacheSettings() -> Bool {
        return self == .CACHE_ALL
    }
    
    static func stringValues() -> [String] {
        var strings: [String] = []
        
        for value in TabsCachingPolicy.allCases
        {
            strings.append(value.rawValue)
        }
        
        return strings
    }
}
