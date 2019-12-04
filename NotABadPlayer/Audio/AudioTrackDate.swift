//
//  AudioTrackDate.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 4.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class AudioTrackDate: Codable {
    public let added: AudioTrackDateValue
    public let firstPlayed: AudioTrackDateValue
    public let lastPlayed: AudioTrackDateValue?
    
    init(_ added: AudioTrackDateValue, _ firstPlayed: AudioTrackDateValue, _ lastPlayed: AudioTrackDateValue?) {
        self.added = added
        self.firstPlayed = firstPlayed
        self.lastPlayed = lastPlayed
    }
}

class AudioTrackDateValue: Codable, Equatable {
    public let value: Date
    
    public init() {
        self.value = Date()
    }
    
    public init(_ value: Date) {
        self.value = value
    }
    
    static func ==(lhs: AudioTrackDateValue, rhs: AudioTrackDateValue) -> Bool {
        return lhs.value == rhs.value
    }
}
