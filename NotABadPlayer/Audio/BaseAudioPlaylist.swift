//
//  BaseAudioPlaylist.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

// Describes a playlist model.
// Thread safe: no
protocol BaseAudioPlaylist {
    var name: String { get }
    var tracks: [BaseAudioTrack] { get }
    var firstTrack: BaseAudioTrack { get }
    var isPlaying: Bool { get }
    var playingTrackPosition: Int { get }
    var playingTrack: BaseAudioTrack { get }
    var isTemporary: Bool { get }
    
    func equals(_ other: BaseAudioPlaylist) -> Bool
    
    func sortedPlaylist(withSorting sorting: TrackSorting) -> MutableAudioPlaylist
    func isAlbumPlaylist() -> Bool
    func size() -> Int
    func trackAt(_ index: Int) -> BaseAudioTrack
    func getAlbum(audioInfo: AudioInfo) -> AudioAlbum?
    func isPlayingFirstTrack() -> Bool
    func isPlayingLastTrack() -> Bool
    func hasTrack(_ track: BaseAudioTrack) -> Bool
}
