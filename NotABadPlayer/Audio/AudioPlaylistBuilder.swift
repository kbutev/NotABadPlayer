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
    
    public static func buildLatestVersionFrom(serializedData :String) throws -> BaseAudioPlaylist {
        if let result: AudioPlaylistV1 = Serializing.deserialize(fromData: serializedData) {
            return result
        }
        
        throw AudioPlaylistBuilderError.deserializationFailed("Failed to deserialize given data")
    }
    
    public static func buildLatestVersionListFrom(serializedData :String) throws -> [BaseAudioPlaylist] {
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
    var sorting: TrackSorting { get set }
    var startWithTrack: AudioTrack? { get set }
    var isTemporary: Bool { get set }
}

class AudioPlaylistBuilderNode: BaseAudioPlaylistBuilderNode {
    var name: String = ""
    var tracks: [AudioTrack] = []
    var sorting: TrackSorting = .NONE
    var startWithTrack: AudioTrack?
    var playingTrackPosition: Int = 0
    var isTemporary: Bool = false
    
    init() {
        sorting = .NONE
    }
    
    init(prototype: BaseAudioPlaylist) {
        name = prototype.name
        tracks = prototype.tracks
        sorting = .NONE
        startWithTrack = prototype.playingTrack
        playingTrackPosition = prototype.playingTrackPosition
        isTemporary = prototype.isTemporary
    }
    
    func build() throws -> BaseAudioPlaylist {
        return try buildMutable()
    }
    
    func buildMutable() throws -> MutableAudioPlaylist {
        if startWithTrack != nil
        {
            // Playlist with one single track
            if tracks.count == 0
            {
                guard let startTrack = startWithTrack else {
                    throw AudioPlaylistBuilderError.invalidBuildParameters("Cannot build playlist with no tracks and no start track")
                }
                
                let playlist = AudioPlaylistV1(name: name, startWithTrack: startTrack)
                playlist.isTemporary = isTemporary
                return playlist
            }
            
            let playlist = AudioPlaylistV1(name: name, tracks: tracks, sorting: sorting)
            playlist.isTemporary = isTemporary
            return playlist
        }
        
        let playlist = AudioPlaylistV1(name: name, tracks: tracks, sorting: sorting)
        playlist.isTemporary = isTemporary
        return playlist
    }
}
