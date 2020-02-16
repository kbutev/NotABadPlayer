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
        get { return super.source }
        set { setSource(newValue) }
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
        super.init()
    }
    
    public override init(_ prototype: AudioTrack) {
        super.init(prototype)
    }
    
    required init(from decoder: Decoder) throws {
        try super.init(from: decoder)
    }
}
