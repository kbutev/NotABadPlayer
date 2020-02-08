//
//  AudioInfo.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

enum SearchTracksFilter : String {
    case Title
    case Album
    case Artist
}

protocol AudioInfo {
    func loadIfNecessary()
    func load()
    
    func getAlbums() -> [AudioAlbum];
    func getAlbum(byID identifier: Int) -> AudioAlbum?
    func getAlbumTracks(album: AudioAlbum) -> [AudioTrack]
    func searchForTracks(query: String, filter: SearchTracksFilter) -> [AudioTrack]
    func recentlyAddedTracks() -> [AudioTrack]
    func favoriteTracks() -> [AudioTrack]
    
    func searchForTracks(mediaQuery: MPMediaQuery, predicate: MPMediaPropertyPredicate?, cap: Int) -> [AudioTrack]
    
    func registerLibraryChangesListener(_ listener: AudioLibraryChangesListener)
    func unregisterLibraryChangesListener(_ listener: AudioLibraryChangesListener)
}
