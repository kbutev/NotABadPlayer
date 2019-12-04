//
//  AudioTrackDateBuilder.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 4.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class AudioTrackDateBuilder {
    public static func buildGeneric() -> AudioTrackDate {
        return AudioTrackDate(AudioTrackDateValue(), AudioTrackDateValue(), nil)
    }
    
    public static func build(_ added: AudioTrackDateValue, _ firstPlayed: AudioTrackDateValue, _ lastPlayed: AudioTrackDateValue?) -> AudioTrackDate {
        return AudioTrackDate(added, firstPlayed, lastPlayed)
    }
}
