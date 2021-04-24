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
    
    func getAlbums() -> [AudioAlbum]
    func getAlbum(byID identifier: Int) -> AudioAlbum?
    func getAlbumTracks(album: AudioAlbum) -> [AudioTrackProtocol]
    func searchForTracks(query: String, filter: SearchTracksFilter) -> [AudioTrackProtocol]
    func recentlyAddedTracks() -> [AudioTrackProtocol]
    func favoriteTracks() -> [AudioTrackProtocol]
    
    func searchForTracks(mediaQuery: MPMediaQuery, predicate: MPMediaPropertyPredicate?, cap: Int) -> [AudioTrackProtocol]
    
    func registerLibraryChangesListener(_ listener: AudioLibraryChangesListener)
    func unregisterLibraryChangesListener(_ listener: AudioLibraryChangesListener)
}
