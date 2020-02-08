//
//  AudioTrack.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioTrack: BaseAudioTrack, Equatable, Codable {
    internal var _identifier : Int
    internal var _filePath : URL?
    internal var _title : String
    internal var _artist : String
    internal var _albumTitle : String
    internal var _albumID : Int
    internal var _albumCover : MPMediaItemArtwork? = nil
    internal var _trackNum : Int
    internal var _durationInSeconds : Double
    internal var _source : AudioTrackSource
    
    internal var _lyrics : String
    internal var _date : AudioTrackDate
    internal var _lastPlayedPosition : TimeInterval
    
    public var identifier : Int {
        get {
            return _identifier
        }
    }
    public var filePath : URL? {
        get {
            return _filePath
        }
    }
    public var title : String {
        get {
            return _title
        }
    }
    public var artist : String {
        get {
            return _artist
        }
    }
    public var albumTitle : String {
        get {
            return _albumTitle
        }
    }
    
    public var albumID : Int {
        get {
            return _albumID
        }
    }
    
    public var albumCover : MPMediaItemArtwork? {
        get {
            if _albumCover != nil
            {
                return _albumCover
            }
            
            _albumCover = retrieveAlbumCoverFromAlbum()
            
            return _albumCover
        }
    }
    
    public var albumCoverImage : UIImage? {
         get {
            if let albumCover = self.albumCover
            {
                return albumCover.image(at: albumCover.bounds.size)
            }
            
            return nil
         }
    }
    
    public var trackNum : Int {
        get {
            return _trackNum
        }
    }
    public var durationInSeconds : Double {
        get {
            return _durationInSeconds
        }
    }
    public var duration : String {
        get {
            return StringUtilities.secondsToString(self._durationInSeconds)
        }
    }
    public var source : AudioTrackSource {
        get {
            return _source
        }
    }
    
    var lyrics : String
    {
        get {
            return _lyrics
        }
    }
    var date : AudioTrackDate
    {
        get {
            return _date
        }
    }
    var lastPlayedPosition : TimeInterval
    {
        get {
            return _lastPlayedPosition
        }
    }
    
    init(albumID: Int, source: AudioTrackSource) {
        self._identifier = 0
        self._filePath = nil
        self._title = ""
        self._artist = ""
        self._albumTitle = ""
        self._trackNum = 0
        self._durationInSeconds = 0
        self._albumID = albumID
        self._source = source
        self._lyrics = ""
        self._date = AudioTrackDateBuilder.buildGeneric()
        self._lastPlayedPosition = 0
    }
    
    static func == (lhs: AudioTrack, rhs: AudioTrack) -> Bool {
        guard let a = lhs.filePath else {
            return false
        }
        guard let b = rhs.filePath else {
            return false
        }
        
        return a == b
    }
    
    func retrieveAlbumCoverFromAlbum() -> MPMediaItemArtwork? {
        let predicate = MPMediaPropertyPredicate(value: albumID, forProperty: MPMediaItemPropertyAlbumPersistentID)
        
        let set = Set(arrayLiteral: predicate)
        
        let query = MPMediaQuery(filterPredicates: set)
        
        if let collection = query.collections?.first
        {
            if let item = collection.items.first
            {
                return item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            }
        }
        
        return nil
    }
    
    // Serialization keys
    // MPMediaItemArtwork should not be codable
    internal enum CodingKeys: String, CodingKey {
        case _identifier
        case _filePath
        case _title
        case _artist
        case _albumTitle
        case _albumID
        case _trackNum
        case _durationInSeconds
        case _source
        case _lyrics
        case _date
        case _lastPlayedPosition
    }
}
