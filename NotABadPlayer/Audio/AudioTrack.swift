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
    
    private var _source : AudioTrackSource
    private var _originalSource : AudioTrackSource
    
    // If the sources are set to a dummy value, this is true.
    // The only case of this is when building with default constructor.
    private var _sourceIsDummy : Bool
    
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
    public var originalSource: AudioTrackSource {
        get {
            return _originalSource
        }
    }
    
    public var lyrics : String
    {
        get {
            return _lyrics
        }
    }
    public var date : AudioTrackDate
    {
        get {
            return _date
        }
    }
    public var lastPlayedPosition : TimeInterval
    {
        get {
            return _lastPlayedPosition
        }
    }
    
    public init() {
        self._identifier = 0
        self._filePath = nil
        self._title = ""
        self._artist = ""
        self._albumTitle = ""
        self._trackNum = 0
        self._durationInSeconds = 0
        self._albumID = 0
        
        self._source = AudioTrackSource.createAlbumSource(albumID: 0)
        self._originalSource = AudioTrackSource.createAlbumSource(albumID: 0)
        self._sourceIsDummy = true
        
        self._lyrics = ""
        self._date = AudioTrackDateBuilder.buildGeneric()
        self._lastPlayedPosition = 0
    }
    
    public init(_ prototype: AudioTrack) {
        self._identifier = prototype._identifier
        self._filePath = prototype._filePath
        self._title = prototype._title
        self._artist = prototype._artist
        self._albumTitle = prototype._albumTitle
        self._trackNum = prototype._trackNum
        self._durationInSeconds = prototype._durationInSeconds
        self._albumID = prototype._albumID
        
        self._source = prototype._source
        self._originalSource = prototype._originalSource
        self._sourceIsDummy = prototype._sourceIsDummy
        
        self._lyrics = prototype._lyrics
        self._date = prototype._date
        self._lastPlayedPosition = prototype._lastPlayedPosition
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
    
    internal func setSource(_ source: AudioTrackSource) {
        _source = source
        
        if _sourceIsDummy {
            _originalSource = source
        }
        
        _sourceIsDummy = false
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
        case _originalSource
        case _sourceIsDummy
        case _lyrics
        case _date
        case _lastPlayedPosition
    }
}
