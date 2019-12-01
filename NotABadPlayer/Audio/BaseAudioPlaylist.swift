//
//  BaseAudioPlaylist.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol BaseAudioPlaylist {
    var name: String { get }
    
    var tracks: [AudioTrack] { get }
    var firstTrack: AudioTrack { get }
    
    var isPlaying: Bool { get }
    var playingTrackPosition: Int { get }
}
