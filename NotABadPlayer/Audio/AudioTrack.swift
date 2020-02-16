//
//  AudioTrack.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioTrack: BaseAudioTrack {
    private var _identifier : Int
    private var _filePath : URL
    private var _title : String
    private var _artist : String
    private var _albumTitle : String
    private var _albumID : Int
    private var _albumCover : MPMediaItemArtwork? = nil
    private var _trackNum : Int
    private var _durationInSeconds : Double
    
    private var _source : AudioTrackSource
    private var _originalSource : AudioTrackSource
    
    // If the sources are set to a dummy value, this is true.
    // The only case of this is when building with default constructor.
    private var _sourceIsDummy : Bool
    
    private var _lyrics : String
    private var _date : AudioTrackDate
    private var _lastPlayedPosition : TimeInterval
    
    override public var identifier : Int {
        get { return _identifier }
        set { _identifier = newValue }
    }
    override public var filePath : URL {
        get { return _filePath }
        set { _filePath = newValue }
    }
    override public var title : String {
        get { return _title }
        set { _title = newValue }
    }
    override public var artist : String {
        get { return _artist }
        set { _artist = newValue }
    }
    override public var albumTitle : String {
        get { return _albumTitle }
        set { _albumTitle = newValue }
    }
    override public var albumID : Int {
        get { return _albumID }
        set { _albumID = newValue }
    }
    override public var albumCover : MPMediaItemArtwork? {
        get {
            if _albumCover != nil
            {
                return _albumCover
            }
            
            _albumCover = retrieveAlbumCoverFromAlbum()
            
            return _albumCover
        }
        set { _albumCover = newValue }
    }
    override public var trackNum : Int {
        get { return _trackNum }
        set { _trackNum = newValue }
    }
    override public var durationInSeconds : Double {
        get { return _durationInSeconds }
        set { _durationInSeconds = newValue }
    }
    override public var duration : String {
        get { return StringUtilities.secondsToString(self._durationInSeconds) }
    }
    override public var source : AudioTrackSource {
        get { return _source }
        set {
            _source = newValue
            
            if _sourceIsDummy {
                _originalSource = newValue
            }
            
            _sourceIsDummy = false
        }
    }
    override public var originalSource : AudioTrackSource {
        get { return _originalSource }
    }
    override public var lyrics : String {
        get { return _lyrics }
        set { _lyrics = newValue }
    }
    override public var date : AudioTrackDate {
        get { return _date }
        set { _date = newValue }
    }
    override public var lastPlayedPosition : TimeInterval {
        get { return _lastPlayedPosition }
        set { _lastPlayedPosition = newValue }
    }
    
    public override init() {
        self._identifier = 0
        self._filePath = URL(fileURLWithPath: "")
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
        
        super.init()
    }
    
    public init(_ prototype: BaseAudioTrack) {
        self._identifier = prototype.identifier
        self._filePath = prototype.filePath
        self._title = prototype.title
        self._artist = prototype.artist
        self._albumTitle = prototype.albumTitle
        self._trackNum = prototype.trackNum
        self._durationInSeconds = prototype.durationInSeconds
        self._albumID = prototype.albumID
        
        self._source = prototype.source
        self._originalSource = prototype.originalSource
        self._sourceIsDummy = (prototype as? AudioTrack)?._sourceIsDummy ?? false
        
        self._lyrics = prototype.lyrics
        self._date = prototype.date
        self._lastPlayedPosition = prototype.lastPlayedPosition
        
        super.init()
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self._identifier = try container.decode(Int.self, forKey: ._identifier)
        self._filePath = try container.decode(URL.self, forKey: ._filePath)
        self._title = try container.decode(String.self, forKey: ._title)
        self._artist = try container.decode(String.self, forKey: ._artist)
        self._albumTitle = try container.decode(String.self, forKey: ._albumTitle)
        self._trackNum = try container.decode(Int.self, forKey: ._trackNum)
        self._durationInSeconds = try container.decode(Double.self, forKey: ._durationInSeconds)
        self._albumID = try container.decode(Int.self, forKey: ._albumID)
        
        self._source = try container.decode(AudioTrackSource.self, forKey: ._source)
        self._originalSource = try container.decode(AudioTrackSource.self, forKey: ._originalSource)
        self._sourceIsDummy = try container.decode(Bool.self, forKey: ._sourceIsDummy)
        
        self._lyrics = try container.decode(String.self, forKey: ._lyrics)
        self._date = try container.decode(AudioTrackDate.self, forKey: ._date)
        self._lastPlayedPosition = try container.decode(Double.self, forKey: ._lastPlayedPosition)
        
        super.init()
    }
    
    override func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(_identifier, forKey: ._identifier)
        try container.encode(_filePath, forKey: ._filePath)
        try container.encode(_title, forKey: ._title)
        try container.encode(_artist, forKey: ._artist)
        try container.encode(_albumTitle, forKey: ._albumTitle)
        try container.encode(_trackNum, forKey: ._trackNum)
        try container.encode(_durationInSeconds, forKey: ._durationInSeconds)
        try container.encode(_albumID, forKey: ._albumID)
        
        try container.encode(_source, forKey: ._source)
        try container.encode(_originalSource, forKey: ._originalSource)
        try container.encode(_sourceIsDummy, forKey: ._sourceIsDummy)
        
        try container.encode(_lyrics, forKey: ._lyrics)
        try container.encode(_date, forKey: ._date)
        try container.encode(_lastPlayedPosition, forKey: ._lastPlayedPosition)
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
        case _originalSource
        case _sourceIsDummy
        case _lyrics
        case _date
        case _lastPlayedPosition
    }
}
