//
//  AudioTrackDateBuilder.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 4.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class AudioTrackDateBuilder {
    private static let initDate = AudioTrackDateValue()
    
    private static let cache: AudioTrackDateBuilderCache = AudioTrackDateBuilderCache()
    
    public static func buildGeneric() -> AudioTrackDate {
        let gerericDate = AudioTrackDateBuilderCache.initDate
        let newDate = AudioTrackDate(gerericDate, gerericDate, nil)
        return cache.getFlyweight(for: newDate)
    }
    
    public static func build(_ added: AudioTrackDateValue, _ firstPlayed: AudioTrackDateValue, _ lastPlayed: AudioTrackDateValue?) -> AudioTrackDate {
        let dateAdded = cache.getFlyweightValue(for: added)
        let dateFirstPlayed = cache.getFlyweightValue(for: firstPlayed)
        var dateLastPlayed: AudioTrackDateValue?
        
        if let dateLastPlayed_ = lastPlayed
        {
            dateLastPlayed = cache.getFlyweightValue(for: dateLastPlayed_)
        }
        
        let newDate = AudioTrackDate(dateAdded, dateFirstPlayed, dateLastPlayed)
        return cache.getFlyweight(for: newDate)
    }
}

class AudioTrackDateBuilderCache {
    static let initDate = AudioTrackDateValue()
    
    private let lock : NSObject = NSObject()
    private var datesCache: Set<AudioTrackDate> = []
    private var dateValuesCache: Set<AudioTrackDateValue> = []
    
    init() {
        dateValuesCache.insert(AudioTrackDateBuilderCache.initDate)
    }
    
    public func getFlyweight(for date: AudioTrackDate) -> AudioTrackDate {
        lockEnter()
        
        defer {
            lockExit()
        }
        
        // If already present in cache, return cached instance
        for cachedDate in datesCache {
            if cachedDate == date {
                return cachedDate
            }
        }
        
        // Otherwise add given date to cache and return it
        datesCache.insert(date)
        
        return date
    }
    
    public func getFlyweightValue(for value: AudioTrackDateValue) -> AudioTrackDateValue {
        lockEnter()
        
        defer {
            lockExit()
        }
        
        // If already present in cache, return cached instance
        for cachedValue in dateValuesCache {
            if cachedValue == value {
                return cachedValue
            }
        }
        
        // Otherwise add given date value to cache and return it
        dateValuesCache.insert(value)
        
        return value
    }
    
    private func lockEnter() {
        objc_sync_enter(self.lock)
    }
    
    private func lockExit() {
        objc_sync_exit(self.lock)
    }
}
