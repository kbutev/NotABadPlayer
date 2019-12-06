//
//  AudioPlaylistBuilder.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

enum AudioPlaylistBuilderError: Error {
    case deserializationFailed(String)
    case invalidBuildParameters(String)
}

class AudioPlaylistBuilder {
    public static func start() -> BaseAudioPlaylistBuilderNode {
        return AudioPlaylistBuilderNode()
    }
    
    public static func start(prototype: BaseAudioPlaylist) -> BaseAudioPlaylistBuilderNode {
        return AudioPlaylistBuilderNode(prototype: prototype)
    }
    
    public static func buildMutableFromImmutable(prototype: BaseAudioPlaylist) throws -> MutableAudioPlaylist {
        return try AudioPlaylistBuilderNode(prototype: prototype).buildMutable()
    }
    
    public static func buildLatestVersionFrom(serializedData: String) throws -> BaseAudioPlaylist {
        return try buildLatestMutableVersionFrom(serializedData: serializedData)
    }
    
    public static func buildLatestMutableVersionFrom(serializedData: String) throws -> MutableAudioPlaylist {
        if let result: AudioPlaylistV1 = Serializing.deserialize(fromData: serializedData) {
            return result
        }
        
        throw AudioPlaylistBuilderError.deserializationFailed("Failed to deserialize given data")
    }
    
    public static func buildLatestVersionListFrom(serializedData: String) throws -> [BaseAudioPlaylist] {
        if let result: [AudioPlaylistV1] = Serializing.deserialize(fromData: serializedData) {
            return result
        }
        
        throw AudioTrackBuilderError.deserializationFailed("Failed to deserialize given data")
    }
    
    public static func buildLatestMutableVersionListFrom(serializedData :String) throws -> [MutableAudioPlaylist] {
        if let result: [AudioPlaylistV1] = Serializing.deserialize(fromData: serializedData) {
            return result
        }
        
        throw AudioTrackBuilderError.deserializationFailed("Failed to deserialize given data")
    }
}

protocol BaseAudioPlaylistBuilderNode {
    func build() throws -> BaseAudioPlaylist
    func buildMutable() throws -> MutableAudioPlaylist
    
    var name: String { get set }
    var tracks: [AudioTrack] { get set }
    var playingTrack: AudioTrack? { get set }
    var playingTrackIndex: Int { get set }
    var isTemporary: Bool { get set }
}

class AudioPlaylistBuilderNode: BaseAudioPlaylistBuilderNode {
    var name: String = ""
    var tracks: [AudioTrack] = []
    var playingTrackIndex: Int = 0
    var isPlaying: Bool = false
    var isTemporary: Bool = false
    
    var playingTrack: AudioTrack? {
        get {
            if playingTrackIndex >= 0 && playingTrackIndex < tracks.count
            {
                return tracks[playingTrackIndex]
            }
            
            return nil
        }
        set {
            if let track = newValue {
                playingTrackIndex = tracks.firstIndex(of: track) ?? 0
            } else {
                playingTrackIndex = 0
            }
        }
    }
    
    init() {
        
    }
    
    init(prototype: BaseAudioPlaylist) {
        name = prototype.name
        tracks = prototype.tracks
        playingTrackIndex = prototype.playingTrackPosition
        isPlaying = prototype.isPlaying
        isTemporary = prototype.isTemporary
    }
    
    func build() throws -> BaseAudioPlaylist {
        return try buildMutable()
    }
    
    func buildMutable() throws -> MutableAudioPlaylist {
        if tracks.count == 0
        {
            throw AudioPlaylistBuilderError.invalidBuildParameters("Cannot build playlist with zero tracks")
        }
        
        return try AudioPlaylistV1(name: name,
                                   tracks: tracks,
                                   startWithTrackIndex: playingTrackIndex,
                                   startPlaying: isPlaying,
                                   isTemporary: isTemporary)
    }
}
