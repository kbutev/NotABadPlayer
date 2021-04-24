//
//  CreateListPickAlbumTracksDelegate.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 22.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import UIKit

// Table data source
class CreateListPickAlbumTracksDataSource : NSObject, BaseCreateListViewAlbumsDataSource
{
    let albums: [AudioAlbum]
    let onOpenedAlbumTrackSelectionCallback: (UInt)->()
    let onOpenedAlbumTrackDeselectionCallback: (UInt)->()
    
    private var selectedAlbumIndex: Int = -1
    private var selectedAlbumCell: CreateListAlbumCell?
    private var selectedAlbumTracks: [CreateListAudioTrack] = []
    private var selectedAlbumDataSource: BaseCreateListAlbumTrackCellDataSource?
    
    private var addedTracks: [CreateListAudioTrack] = []
    
    init(albums: [AudioAlbum],
         onOpenedAlbumTrackSelectionCallback: @escaping (UInt)->(),
         onOpenedAlbumTrackDeselectionCallback: @escaping (UInt)->()) {
        self.albums = albums
        self.onOpenedAlbumTrackSelectionCallback = onOpenedAlbumTrackSelectionCallback
        self.onOpenedAlbumTrackDeselectionCallback = onOpenedAlbumTrackDeselectionCallback
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: CreateListAlbumCell.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? CreateListAlbumCell else {
            return reusableCell
        }
        
        let item = albums[indexPath.row]
        
        cell.coverImage.image = item.albumCoverImage
        cell.titleLabel.text = item.albumTitle
        
        // Selected album - display, update callbacks and update table data source
        if indexPath.row == selectedAlbumIndex
        {
            self.selectedAlbumCell = cell
            
            cell.tracksTable.isHidden = false
            
            cell.onOpenedAlbumTrackSelectionCallback = onOpenedAlbumTrackSelectionCallback
            cell.onOpenedAlbumTrackDeselectionCallback = onOpenedAlbumTrackDeselectionCallback
            
            self.selectedAlbumDataSource = CreateListAlbumTrackCellDataSource(tracks: selectedAlbumTracks)
            cell.tracksTable.dataSource = self.selectedAlbumDataSource
            cell.tracksTable.reloadData()
            
            updateSelectedAlbumTracks()
        }
        else
        {
            cell.tracksTable.isHidden = true
            cell.tracksTable.dataSource = nil
            
            cell.onOpenedAlbumTrackSelectionCallback = {(index)->() in }
            cell.onOpenedAlbumTrackDeselectionCallback = {(index)->() in }
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func getTrackDescription(track: AudioTrackProtocol) -> String {
        return track.duration
    }
    
    public func openAlbum(index: UInt, albumTracks: [CreateListAudioTrack], addedTracks: [CreateListAudioTrack]) {
        if self.selectedAlbumIndex == Int(index)
        {
            self.closeAlbum()
            return
        }
        
        self.selectedAlbumIndex = Int(index)
        self.selectedAlbumCell = nil
        self.selectedAlbumTracks = albumTracks
        self.addedTracks = addedTracks
    }
    
    public func closeAlbum() {
        self.selectedAlbumIndex = -1
        self.selectedAlbumCell = nil
        self.selectedAlbumTracks = []
        self.addedTracks = []
    }
    
    private func updateSelectedAlbumTracks() {
        guard let selectedAlbum = self.selectedAlbumCell else {
            return
        }
        
        for e in 0..<addedTracks.count
        {
            let trackToSelect = addedTracks[e]
            
            // Find the corresponding index
            for i in 0..<selectedAlbumTracks.count
            {
                let albumTrack = selectedAlbumTracks[i]
                
                if albumTrack == trackToSelect
                {
                    selectedAlbum.selectAlbumTrack(at: UInt(i))
                }
            }
        }
    }
    
    public func deselectAlbumTrack(_ track: CreateListAudioTrack) {
        guard let selectedAlbum = self.selectedAlbumCell else {
            return
        }
        
        for e in 0..<selectedAlbumTracks.count
        {
            let albumTrack = selectedAlbumTracks[e]
            
            if albumTrack == track
            {
                selectedAlbum.deselectAlbumTrack(at: UInt(e))
                break
            }
        }
    }
}

// Table action delegate
class CreateListPickAlbumTracksDelegate : NSObject, BaseCreateListPickAlbumTracksDelegate
{
    private weak var view: CreateListView?
    
    private var selectedAlbumIndex: Int = -1
    private var selectedAlbumTracksCount: UInt = 0
    
    init(view: CreateListView) {
        self.view = view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view?.actionAlbumClick(index: UInt(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if selectedAlbumIndex == indexPath.row
        {
            return CreateListAlbumCell.SELECTED_SIZE.height
        }
        
        return CreateListAlbumCell.SIZE.height
    }
    
    public func selectAlbum(index: UInt, albumTracks: [CreateListAudioTrack]) {
        if self.selectedAlbumIndex == Int(index)
        {
            self.deselectAlbum()
            return
        }
        
        self.selectedAlbumIndex = Int(index)
        self.selectedAlbumTracksCount = UInt(albumTracks.count)
    }
    
    public func deselectAlbum() {
        self.selectedAlbumIndex = -1
        self.selectedAlbumTracksCount = 0
    }
}

// Table data source
class CreateListAlbumTrackCellDataSource : NSObject, BaseCreateListAlbumTrackCellDataSource
{
    let tracks: [CreateListAudioTrack]
    
    init(tracks: [CreateListAudioTrack]) {
        self.tracks = tracks
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reusableCell = tableView.dequeueReusableCell(withIdentifier: CreateListAlbumCell.CELL_IDENTIFIER, for: indexPath)
        
        guard let cell = reusableCell as? CreateListAlbumTrackCell else {
            return reusableCell
        }
        
        let item = tracks[indexPath.row]
        
        cell.titleLabel.text = item.title
        cell.descriptionLabel.text = item.description
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

// Table delegate
class CreateListAlbumTrackCellDelegate : NSObject, BaseCreateListAlbumTrackCellDelegate
{
    private weak var view: CreateListAlbumCell?
    
    init(view: CreateListAlbumCell) {
        self.view = view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view?.actionOnTrackSelection(UInt(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.view?.actionOnTrackDeselection(UInt(indexPath.row))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CreateListAlbumTrackCell.HEIGHT
    }
}
