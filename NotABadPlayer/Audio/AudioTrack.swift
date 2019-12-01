//
//  AudioTrack.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioTrack: Equatable, Codable {
    public let identifier : Int
    public let filePath : URL
    public let title : String
    public let artist : String
    public let albumTitle : String
    
    private let _albumID : String
    
    public var albumID : Int {
        get {
            return Int(_albumID) ?? 0
        }
    }
    
    public var _albumCover : MPMediaItemArtwork? = nil
    
    public var albumCover : MPMediaItemArtwork? {
        get {
            if _albumCover != nil
            {
                return _albumCover
            }
            
            let predicate = MPMediaPropertyPredicate(value: albumID, forProperty: MPMediaItemPropertyAlbumPersistentID)
            
            let set = Set(arrayLiteral: predicate)
            
            let query = MPMediaQuery(filterPredicates: set)
            
            if let collection = query.collections?.first
            {
                if let item = collection.items.first
                {
                    _albumCover = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
                }
            }
            
            return _albumCover
        }
    }
    
    public let trackNum : Int
    public let durationInSeconds : Double
    public var duration : String {
        get {
            return StringUtilities.secondsToString(self.durationInSeconds)
        }
    }
    public let source : AudioTrackSource
    
    init(identifier : Int,
         filePath : URL,
         title : String,
         artist : String,
         albumTitle : String,
         albumID : Int,
         albumCover : MPMediaItemArtwork?,
         trackNum : Int,
         durationInSeconds : Double,
         source: AudioTrackSource) {
        self.identifier = identifier
        self.filePath = filePath
        self.title = title
        self.artist = artist
        self.albumTitle = albumTitle
        self._albumID = "\(albumID)"
        self._albumCover = albumCover
        self.trackNum = trackNum
        self.durationInSeconds = durationInSeconds
        self.source = source
    }
    
    init(originalTrack : AudioTrack, source: AudioTrackSource) {
        self.identifier = originalTrack.identifier
        self.filePath = originalTrack.filePath
        self.title = originalTrack.title
        self.artist = originalTrack.artist
        self.albumTitle = originalTrack.albumTitle
        self._albumID = originalTrack._albumID
        self._albumCover = originalTrack._albumCover
        self.trackNum = originalTrack.trackNum
        self.durationInSeconds = originalTrack.durationInSeconds
        self.source = source
    }
    
    static func == (lhs: AudioTrack, rhs: AudioTrack) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    // Serialization keys
    // MPMediaItemArtwork should not be codable
    private enum CodingKeys: String, CodingKey {
        case identifier
        case filePath
        case title
        case artist
        case albumTitle
        case _albumID
        case trackNum
        case durationInSeconds
        case source
    }
}
