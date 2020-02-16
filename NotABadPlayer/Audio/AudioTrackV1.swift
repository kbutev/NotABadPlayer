//
//  AudioTrackV1.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioTrackV1 : AudioTrack {
    override init() {
        super.init()
    }
    
    override init(_ prototype: BaseAudioTrack) {
        super.init(prototype)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
