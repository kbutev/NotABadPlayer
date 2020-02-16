//
//  BaseAudioTrack.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

class BaseAudioTrack: Equatable, Codable {
    var identifier : Int { get { return 0 } }
    var filePath : URL { get { return URL(fileURLWithPath: "") } }
    var title : String { get { return "" } }
    var artist : String { get { return "" } }
    var albumTitle : String { get { return "" } }
    var albumID : Int { get { return 0 } }
    var albumCover : MPMediaItemArtwork? { get { return nil } }
    var trackNum : Int { get { return 0 } }
    var durationInSeconds : Double { get { return 0 } }
    var duration : String { get { return "" } }
    var source : AudioTrackSource { get { return AudioTrackSource.createAlbumSource(albumID: 0) } }
    var originalSource : AudioTrackSource { get { return AudioTrackSource.createAlbumSource(albumID: 0) } }
    
    var lyrics : String { get { return "" } }
    var date : AudioTrackDate { get { return AudioTrackDate(AudioTrackDateValue(), AudioTrackDateValue(), AudioTrackDateValue()) } }
    var lastPlayedPosition : TimeInterval { get { return 0 } }
    
    // Album cover getter helper.
    public var albumCoverImage : UIImage? {
        get {
            if let albumCover = self.albumCover
            {
                return albumCover.image(at: albumCover.bounds.size)
            }
            
            return nil
        }
    }
    
    static func == (lhs: BaseAudioTrack, rhs: BaseAudioTrack) -> Bool {
        return lhs.filePath == rhs.filePath
    }
}
