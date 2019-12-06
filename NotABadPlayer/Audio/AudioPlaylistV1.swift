//
//  AudioPlaylistV1.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class AudioPlaylistV1 : MutableAudioPlaylist {
    override init(_ prototype: MutableAudioPlaylist) {
        super.init(prototype)
    }
    
    convenience init(name: String, tracks: [AudioTrack]) throws {
        try self.init(name: name,
                      tracks: tracks,
                      startWithTrackIndex: 0,
                      startPlaying: false,
                      isTemporary: false)
    }
    
    override init(name: String,
                     tracks: [AudioTrack],
                     startWithTrackIndex: Int,
                     startPlaying: Bool,
                     isTemporary: Bool) throws {
        try super.init(name: name,
                       tracks: tracks,
                       startWithTrackIndex: startWithTrackIndex,
                       startPlaying: startPlaying,
                       isTemporary: isTemporary)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
    
    static func == (lhs: AudioPlaylistV1, rhs: AudioPlaylistV1) -> Bool {
        return lhs.name == rhs.name && lhs.playingTrackPosition == rhs.playingTrackPosition && lhs.tracks == rhs.tracks
    }
    
    override func equals(_ other: BaseAudioPlaylist) -> Bool {
        if let other_ = other as? AudioPlaylistV1 {
            return self == other_
        }
        
        return false
    }
}
