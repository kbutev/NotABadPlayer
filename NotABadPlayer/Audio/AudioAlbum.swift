//
//  AudioAlbum.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

class AudioAlbum: Equatable, Codable {
    public var albumID : Int {
        get {
            return Int(_albumID) ?? 0
        }
    }
    
    private let _albumID : String
    
    public let albumArtist : String
    public let albumTitle : String
    
    public var albumCover : MPMediaItemArtwork? {
        get {
            if _albumCover != nil
            {
                return _albumCover
            }
            
            let predicate = MPMediaPropertyPredicate(value: albumID, forProperty: MPMediaItemPropertyAlbumPersistentID)
            
            let set = Set(arrayLiteral: predicate)
            
            let query = MPMediaQuery(filterPredicates: set)
            
            if let item = query.collections?.first
            {
                _albumCover = item.value(forProperty: MPMediaItemPropertyArtwork) as? MPMediaItemArtwork
            }
            
            return _albumCover
        }
    }
    
    public var albumCoverImage : UIImage? {
        get {
            if let albumCover = self.albumCover {
                return albumCover.image(at: albumCover.bounds.size)
            }
            
            return UIImage(named: "cover_album_unknown")
        }
    }
    
    public var hasCoverImage : Bool {
        return self.albumCover != nil
    }
    
    public var _albumCover : MPMediaItemArtwork? = nil
    
    init(albumID : NSNumber, albumArtist : String, albumTitle : String, albumCover : MPMediaItemArtwork?) {
        self._albumID = albumID.stringValue
        self.albumArtist = albumArtist
        self.albumTitle = albumTitle
        self._albumCover = albumCover
    }
    
    static func == (lhs: AudioAlbum, rhs: AudioAlbum) -> Bool {
        return lhs._albumID == rhs._albumID
    }
    
    // MPMediaItemArtwork should not be codable
    private enum CodingKeys: String, CodingKey {
        case _albumID
        case albumArtist
        case albumTitle
    }
}
