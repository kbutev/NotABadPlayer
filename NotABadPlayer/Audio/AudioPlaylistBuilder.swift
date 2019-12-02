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
    var playingTrack: AudioTrack?
    var playingTrackIndex: Int = 0
    var isTemporary: Bool = false
    
    init() {
        
    }
    
    init(prototype: BaseAudioPlaylist) {
        name = prototype.name
        tracks = prototype.tracks
        playingTrack = prototype.playingTrack
        playingTrackIndex = prototype.isPlaying ? prototype.playingTrackPosition : -1
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
        
        var playlist: AudioPlaylistV1? = nil
        
        if let startTrack = playingTrack
        {
            playlist = try AudioPlaylistV1(name: name, tracks: tracks, startWithTrack: startTrack)
        }
        else if playingTrackIndex != -1
        {
            if playingTrackIndex < 0 || playingTrackIndex >= tracks.count
            {
                throw AudioPlaylistBuilderError.invalidBuildParameters("Cannot build playlist with invalid play track index")
            }
            
            playlist = try AudioPlaylistV1(name: name, tracks: tracks, startWithTrackIndex: playingTrackIndex)
        } else {
            playlist = AudioPlaylistV1(name: name, tracks: tracks)
        }
        
        playlist?.isTemporary = isTemporary
        
        return playlist!
    }
}
