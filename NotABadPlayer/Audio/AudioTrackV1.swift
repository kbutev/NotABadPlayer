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
    override public var identifier : Int {
        get { return _identifier }
        set { _identifier = newValue }
    }
    override public var filePath : URL? {
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
    override public var source : AudioTrackSource {
        get { return _source }
        set { _source = newValue }
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
    
    public init() {
        super.init(albumID: 0, source: AudioTrackSource.createAlbumSource(albumID: 0))
    }
    
    public init(_ prototype: AudioTrack) {
        super.init(albumID: prototype.albumID, source: prototype.source)
        self.identifier = prototype.identifier
        self.filePath = prototype.filePath
        self.title = prototype.title
        self.artist = prototype.artist
        self.albumTitle = prototype.albumTitle
        self.albumID = prototype.albumID
        self.albumCover = prototype.albumCover
        self.trackNum = prototype.trackNum
        self.durationInSeconds = prototype.durationInSeconds
        
        self.lyrics = prototype.lyrics
        self.date = prototype.date
        self.lastPlayedPosition = prototype.lastPlayedPosition
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
