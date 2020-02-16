//
//  MediaSorting.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

struct MediaSorting {
    public static func sortTracks(_ tracks:[BaseAudioTrack], sorting: TrackSorting) -> [BaseAudioTrack] {
        switch sorting
        {
        case .NONE:
            return tracks
        case .TRACK_NUMBER:
            return sortTracksByTrackNumber(tracks)
        case .TITLE:
            return sortTracksByTitle(tracks)
        case .LONGEST:
            return sortTracksByLength(tracks, longest: true)
        case .SHORTEST:
            return sortTracksByLength(tracks, longest: false)
        }
    }
    
    public static func sortTracksByTrackNumber(_ tracks:[BaseAudioTrack]) -> [BaseAudioTrack] {
        var result = tracks
        
        result.sort(by: {(trackA, trackB) -> Bool in
            let trackNumLString = String(format: "%02d", trackA.trackNum)
            let trackNumRString = String(format: "%02d", trackB.trackNum)
            return trackNumLString < trackNumRString
        })
        
        return result
    }
    
    public static func sortTracksByTitle(_ tracks:[BaseAudioTrack]) -> [BaseAudioTrack] {
        var result = tracks
        
        result.sort(by: {(trackA, trackB) -> Bool in
            return trackA.title < trackB.title
        })
        
        return result
    }
    
    public static func sortTracksByLength(_ tracks:[BaseAudioTrack], longest: Bool=true) -> [BaseAudioTrack] {
        var result = tracks
        
        if longest {
            result.sort(by: {(trackA, trackB) -> Bool in
                return trackA.duration > trackB.duration
            })
        } else {
            result.sort(by: {(trackA, trackB) -> Bool in
                return trackA.duration < trackB.duration
            })
        }
        
        return result
    }
    
    public static func sortAlbumsByTitle(_ albums:[AudioAlbum]) -> [AudioAlbum] {
        var result = albums
        
        result.sort(by: {(trackA, trackB) -> Bool in
            return trackA.albumTitle < trackB.albumTitle
        })
        
        return result
    }
}
