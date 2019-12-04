//
//  AudioTrackBuilder.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

enum AudioTrackBuilderError: Error {
    case deserializationFailed(String)
}

class AudioTrackBuilder {
    public static func start() -> BaseAudioTrackBuilderNode {
        return AudioTrackBuilderNode()
    }
    
    public static func start(prototype: AudioTrack) -> BaseAudioTrackBuilderNode {
        return AudioTrackBuilderNode(prototype: prototype)
    }
    
    public static func buildLatestVersionFrom(serializedData :String) throws -> AudioTrack {
        if let result: AudioTrackV1 = Serializing.deserialize(fromData: serializedData) {
            return result
        }
        
        throw AudioTrackBuilderError.deserializationFailed("Failed to deserialize given data")
    }
    
    public static func buildLatestVersionListFrom(serializedData :String) throws -> [AudioTrack] {
        if let result: [AudioTrackV1] = Serializing.deserialize(fromData: serializedData) {
            return result
        }
        
        throw AudioTrackBuilderError.deserializationFailed("Failed to deserialize given data")
    }
}

protocol BaseAudioTrackBuilderNode {
    func build() throws -> AudioTrack
    func reset()
    
    var identifier : Int { get set}
    var filePath : URL? { get set}
    var title : String { get set}
    var artist : String { get set}
    var albumTitle : String { get set}
    var albumID : Int { get set}
    var albumCover : MPMediaItemArtwork? { get set}
    var trackNum : Int { get set}
    var durationInSeconds : Double { get set}
    var source : AudioTrackSource { get set}
}

class AudioTrackBuilderNode: BaseAudioTrackBuilderNode {
    static let genericOrigin: AudioTrackV1 = AudioTrackV1()
    
    var template: AudioTrack
    var track: AudioTrackV1
    
    public var identifier : Int {
        get { return track.identifier }
        set { track.identifier = newValue }
    }
    public var filePath : URL? {
        get { return track.filePath }
        set { track.filePath = newValue }
    }
    public var title : String {
        get { return track.title }
        set { track.title = newValue }
    }
    public var artist : String {
        get { return track.artist }
        set { track.artist = newValue }
    }
    public var albumTitle : String {
        get { return track.albumTitle }
        set { track.albumTitle = newValue }
    }
    public var albumID : Int {
        get { return track.albumID }
        set { track.albumID = newValue }
    }
    public var albumCover : MPMediaItemArtwork? {
        get { return track.albumCover }
        set { track.albumCover = newValue }
    }
    public var trackNum : Int {
        get { return track.trackNum }
        set { track.trackNum = newValue }
    }
    public var durationInSeconds : Double {
        get { return track.durationInSeconds }
        set { track.durationInSeconds = newValue }
    }
    public var source : AudioTrackSource {
        get { return track.source }
        set { track.source = newValue }
    }
    
    init() {
        template = AudioTrackBuilderNode.genericOrigin
        track = AudioTrackBuilderNode.genericOrigin
        reset()
    }
    
    init(prototype: AudioTrack) {
        template = prototype
        track = AudioTrackBuilderNode.genericOrigin
        reset()
    }
    
    func build() throws -> AudioTrack {
        let track = self.track
        self.track = AudioTrackV1()
        return track
    }
    
    func reset() {
        track = AudioTrackV1(template)
    }
}
