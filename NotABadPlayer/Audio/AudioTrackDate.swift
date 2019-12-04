//
//  AudioTrackDate.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 4.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class AudioTrackDate: Codable, Equatable, Hashable {
    public static let nilDateReference: AudioTrackDateValue = AudioTrackDateValue()
    
    public let added: AudioTrackDateValue
    public let firstPlayed: AudioTrackDateValue
    public let lastPlayed: AudioTrackDateValue?
    
    init(_ added: AudioTrackDateValue, _ firstPlayed: AudioTrackDateValue, _ lastPlayed: AudioTrackDateValue?) {
        self.added = added
        self.firstPlayed = firstPlayed
        self.lastPlayed = lastPlayed
    }
    
    static func ==(lhs: AudioTrackDate, rhs: AudioTrackDate) -> Bool {
        return lhs.added == rhs.added && lhs.firstPlayed == rhs.firstPlayed && lhs.lastPlayed == rhs.lastPlayed
    }
    
    func hash(into hasher: inout Hasher) {
        if let lastPlayedValue = lastPlayed {
            hasher.combine(added)
            hasher.combine(firstPlayed)
            hasher.combine(lastPlayedValue)
        } else {
            hasher.combine(added)
            hasher.combine(firstPlayed)
        }
    }
}

class AudioTrackDateValue: Codable, Equatable, Hashable {
    public static let nilDateReference: AudioTrackDateValue = AudioTrackDateValue()
    
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
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(value)
    }
}
