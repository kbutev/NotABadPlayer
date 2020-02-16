//
//  OpenPlaylistOptions.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 16.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import Foundation

struct OpenPlaylistOptions {
    public var openOriginalSourcePlaylist = false
    
    // Interface
    public var displayHeader = true
    public var displayFavoriteIcon = true
    public var displayTrackNumber = true
    public var displayDescriptionDuration = true
    public var displayDescriptionAlbumTitle = false
    
    public static func buildDefault() -> OpenPlaylistOptions
    {
        return OpenPlaylistOptions()
    }
    
    public static func buildFavorites() -> OpenPlaylistOptions
    {
        var options = OpenPlaylistOptions()
        options.openOriginalSourcePlaylist = true
        options.displayDescriptionAlbumTitle = true
        options.displayTrackNumber = false
        return options
    }
    
    public static func buildRecentlyAdded() -> OpenPlaylistOptions
    {
        var options = OpenPlaylistOptions()
        options.openOriginalSourcePlaylist = true
        options.displayDescriptionAlbumTitle = true
        options.displayTrackNumber = false
        return options
    }
}
