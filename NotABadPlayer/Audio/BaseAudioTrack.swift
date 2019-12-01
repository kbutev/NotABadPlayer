//
//  BaseAudioTrack.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

protocol BaseAudioTrack {
    var identifier : Int { get }
    var filePath : URL? { get }
    var title : String { get }
    var artist : String { get }
    var albumTitle : String { get }
    var albumID : Int { get }
    var albumCover : MPMediaItemArtwork? { get }
    var trackNum : Int { get }
    var durationInSeconds : Double { get }
    var duration : String { get }
    var source : AudioTrackSource { get }
}
