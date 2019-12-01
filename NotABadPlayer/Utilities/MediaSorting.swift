//
//  MediaSorting.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

struct MediaSorting {
    public static func sortTracks(_ tracks:[AudioTrack], sorting: TrackSorting) -> [AudioTrack] {
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
    
    public static func sortTracksByTrackNumber(_ tracks:[AudioTrack]) -> [AudioTrack] {
        var result = tracks
        
        result.sort(by: {(e1, e2) -> Bool in
            let numL = e1.trackNum == 2 ? "\(e1.trackNum)" : "0\(e1.trackNum)"
            let numR = e2.trackNum == 2 ? "\(e2.trackNum)" : "0\(e2.trackNum)"
            return numL < numR
        })
        
        return result
    }
    
    public static func sortTracksByTitle(_ tracks:[AudioTrack]) -> [AudioTrack] {
        var result = tracks
        
        result.sort(by: {(e1, e2) -> Bool in
            return e1.title < e2.title
        })
        
        return result
    }
    
    public static func sortTracksByLength(_ tracks:[AudioTrack], longest: Bool=true) -> [AudioTrack] {
        var result = tracks
        
        if longest {
            result.sort(by: {(e1, e2) -> Bool in
                return e1.duration > e2.duration
            })
        } else {
            result.sort(by: {(e1, e2) -> Bool in
                return e1.duration < e2.duration
            })
        }
        
        return result
    }
    
    public static func sortAlbumsByTitle(_ albums:[AudioAlbum]) -> [AudioAlbum] {
        var result = albums
        
        result.sort(by: {(e1, e2) -> Bool in
            return e1.albumTitle < e2.albumTitle
        })
        
        return result
    }
}
