//
//  AppSettings.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

enum TabID: String {
    case None;
    case Albums;
    case Lists;
    case Search;
    case Settings;
}

enum AppTheme: String {
    case LIGHT;
    case DARK;
    case MIX;
}

enum AlbumSorting: String {
    case TITLE;
}

enum TrackSorting: String {
    case TRACK_NUMBER;
    case TITLE;
    case LONGEST;
    case SHORTEST;
}

enum ShowStars: String {
    case YES;
    case PLAYER_ONLY;
    case TRACK_ONLY;
    case NO;
}

enum ShowVolumeBar: String {
    case NO;
    case LEFT_SIDE;
    case RIGHT_SIDE;
}

enum TabsCachingPolicy: String {
    case NO_CACHING;
    case ALBUMS_ONLY;
    case CACHE_ALL;
}
