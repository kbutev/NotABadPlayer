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
    public static func start() -> AudioPlaylistBuilderNodeProtocol {
        return AudioPlaylistBuilderNode()
    }
    
    public static func start(prototype: AudioPlaylistProtocol) -> AudioPlaylistBuilderNodeProtocol {
        return AudioPlaylistBuilderNode(prototype: prototype)
    }
    
    public static func buildMutableFromImmutable(prototype: AudioPlaylistProtocol) throws -> MutableAudioPlaylist {
        return try AudioPlaylistBuilderNode(prototype: prototype).buildMutable()
    }
    
    public static func buildLatestVersionFrom(serializedData: String) throws -> AudioPlaylistProtocol {
        return try buildLatestMutableVersionFrom(serializedData: serializedData)
    }
    
    public static func buildLatestMutableVersionFrom(serializedData: String) throws -> MutableAudioPlaylist {
        if let result: AudioPlaylistV1 = Serializing.jsonDeserialize(fromString: serializedData) {
            return result
        }
        
        throw AudioPlaylistBuilderError.deserializationFailed("Failed to deserialize given data")
    }
    
    public static func buildLatestVersionListFrom(serializedData: String) throws -> [AudioPlaylistProtocol] {
        if let result: [AudioPlaylistV1] = Serializing.jsonDeserialize(fromString: serializedData) {
            return result
        }
        
        throw AudioTrackBuilderError.deserializationFailed("Failed to deserialize given data")
    }
    
    public static func buildLatestMutableVersionListFrom(serializedData :String) throws -> [MutableAudioPlaylist] {
        if let result: [AudioPlaylistV1] = Serializing.jsonDeserialize(fromString: serializedData) {
            return result
        }
        
        throw AudioTrackBuilderError.deserializationFailed("Failed to deserialize given data")
    }
}

protocol AudioPlaylistBuilderNodeProtocol {
    func build() throws -> AudioPlaylistProtocol
    func buildMutable() throws -> MutableAudioPlaylist
    
    var name: String { get set }
    var tracks: [AudioTrackProtocol] { get set }
    var playingTrack: AudioTrackProtocol? { get set }
    var playingTrackIndex: Int { get set }
    var isTemporary: Bool { get set }
}

class AudioPlaylistBuilderNode: AudioPlaylistBuilderNodeProtocol {
    var name: String = ""
    var tracks: [AudioTrackProtocol] = []
    var playingTrackIndex: Int = 0
    var isPlaying: Bool = false
    var isTemporary: Bool = false
    
    var playingTrack: AudioTrackProtocol? {
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
    
    init(prototype: AudioPlaylistProtocol) {
        name = prototype.name
        tracks = prototype.tracks
        playingTrackIndex = prototype.playingTrackPosition
        isPlaying = prototype.isPlaying
        isTemporary = prototype.isTemporary
    }
    
    func build() throws -> AudioPlaylistProtocol {
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
