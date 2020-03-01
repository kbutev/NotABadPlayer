//
//  ListsProtocols.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol BaseListsViewDataSource : UITableViewDataSource {
    var count: Int { get }
    
    func data(at index: UInt) -> BaseAudioPlaylist
}

protocol BaseListsViewDelegate : UITableViewDelegate {
    
}

protocol BaseCreateListAddedTracksTableDataSource : UITableViewDataSource {
    func getTrackDescription(track: BaseAudioTrack) -> String
}

protocol BaseCreateListAddedTracksActionDelegate : UITableViewDelegate {
    
}

protocol BaseCreateListViewAlbumsDataSource : UITableViewDataSource {
    func openAlbum(index: UInt, albumTracks: [CreateListAudioTrack], addedTracks: [CreateListAudioTrack])
    func closeAlbum()
    func deselectAlbumTrack(_ track: CreateListAudioTrack)
}

protocol BaseCreateListPickAlbumTracksDelegate : UITableViewDelegate {
    func selectAlbum(index: UInt, albumTracks: [CreateListAudioTrack])
    func deselectAlbum()
}

protocol BaseCreateListAlbumTrackCellDataSource : UITableViewDataSource {
    
}

protocol BaseCreateListAlbumTrackCellDelegate : UITableViewDelegate {
    
}
