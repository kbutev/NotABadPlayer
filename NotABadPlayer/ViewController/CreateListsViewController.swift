//
//  CreateListsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class CreateListsViewController: UIViewController {
    public static let PLAYLIST_NAME_LENGTH_LIMIT = 16
    
    private var baseView: CreateListView?
    
    private let audioInfo: AudioInfo!
    private var audioInfoAlbums: [AudioAlbum] = []
    private var addedTracks: [AudioTrack] = []
    private var addedTracksAsViewModels: [CreateListAudioTrack] {
        get {
            var result: [CreateListAudioTrack] = []
            
            for track in self.addedTracks
            {
                result.append(CreateListAudioTrack.createFrom(track))
            }
            
            return result
        }
    }
    private var openedAlbum: AudioAlbum?
    private var openedAlbumTracks: [AudioTrack] = []
    private var openedAlbumTracksAsViewModels: [CreateListAudioTrack] {
        get {
            var result: [CreateListAudioTrack] = []
            
            for track in self.openedAlbumTracks
            {
                result.append(CreateListAudioTrack.createFrom(track))
            }
            
            return result
        }
    }
    
    private var playlistName: String = ""
    
    private var addedTracksTableDataSource: BaseCreateListViewAddedTracksTableDataSource?
    private var albumsDataSource: BaseCreateListViewAlbumsDataSource?
    
    private var onOpenedAlbumTrackSelectionCallback: (UInt)->Void = {(index) in }
    private var onOpenedAlbumTrackDeselectionCallback: (UInt)->Void = {(index) in }
    
    init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.audioInfo = nil
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = CreateListView.create(owner: self)
        self.view = self.baseView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.audioInfoAlbums = audioInfo?.getAlbums() ?? []
        
        setup()
    }
    
    private func setup() {
        baseView?.onTextFieldEditedCallback = {[weak self] (text) in
            if text.count < CreateListsViewController.PLAYLIST_NAME_LENGTH_LIMIT
            {
                self?.playlistName = text
            }
            else
            {
                self?.playlistName = String(text.prefix(CreateListsViewController.PLAYLIST_NAME_LENGTH_LIMIT))
            }
        }
        
        baseView?.onCancelButtonClickedCallback = {[weak self] () in
            self?.goBack()
        }
        
        baseView?.onDoneButtonClickedCallback = {[weak self] () in
            self?.saveUserPlaylist()
        }
        
        baseView?.onAlbumClickedCallback = {[weak self] (index) in
            self?.openAlbumAt(index: index)
        }
        
        // When clicking an added track:
        // Remove it from current list model
        // Deselect it from opened album (if there is one)
        baseView?.onAddedTrackClickedCallback = {[weak self] (index: UInt) -> Void in
            if let strongSelf = self
            {
                if let track = strongSelf.getAddedTrackAt(index)
                {
                    strongSelf.deselectTrackInOpenedAlbum(CreateListAudioTrack.createFrom(track))
                }
                
                strongSelf.removeTrackFromAddedTracks(at: index)
            }
        }
        
        // When selecting an opened album track:
        // Add it to the current list model
        self.onOpenedAlbumTrackSelectionCallback = {[weak self] (index: UInt) -> Void in
            self?.addTrackToAddedTracks(fromOpenedAlbumIndex: index)
        }
        
        // When deselecting an opened album track:
        // Remove from to the current list model
        self.onOpenedAlbumTrackDeselectionCallback = {[weak self] (index: UInt) -> Void in
            self?.removeTrackFromAddedTracks(withOpenedAlbumIndex: index)
        }
        
        updateAlbumsView()
    }
    
    private func goBack() {
        NavigationHelpers.dismissPresentedVC(self)
    }
    
    private func updateAddedTracksView() {
        self.addedTracksTableDataSource = CreateListViewAddedTracksTableDataSource(audioInfo: audioInfo, tracks: addedTracks)
        
        baseView?.addedTracksTableDataSource = self.addedTracksTableDataSource
        
        baseView?.reloadAddedTracksData()
    }
    
    private func updateAlbumsView() {
        self.albumsDataSource = CreateListViewAlbumsDataSource(albums: self.audioInfoAlbums,
                                                               onOpenedAlbumTrackSelectionCallback: self.onOpenedAlbumTrackSelectionCallback,
                                                               onOpenedAlbumTrackDeselectionCallback: self.onOpenedAlbumTrackDeselectionCallback)
        
        baseView?.albumsTableDataSource = self.albumsDataSource
        
        baseView?.reloadAlbumsData()
    }
    
    public func saveUserPlaylist() {
        if playlistName.count == 0
        {
            showPlaylistNameEmptyError()
            return
        }
        
        if addedTracks.count == 0
        {
            showPlaylistEmptyError()
            return
        }
        
        var storagePlaylists = GeneralStorage.shared.getUserPlaylists()
        
        for storagePlaylist in storagePlaylists
        {
            if playlistName == storagePlaylist.name
            {
                showPlaylistAlreadyExistsError()
                return
            }
        }
        
        var node = AudioPlaylistBuilder.start()
        node.name = playlistName
        node.tracks = addedTracks
        
        do {
            let result = try node.buildMutable()
            storagePlaylists.append(result)
        } catch {
            Logging.log(CreateListsViewController.self, "Failed to save user playlist '\(playlistName)' with \(addedTracks.count) tracks to storage, failed to build playlist")
            showPlaylistUnknownError()
            return
        }
        
        // Save
        GeneralStorage.shared.saveUserPlaylists(storagePlaylists)
        
        Logging.log(CreateListsViewController.self, "Saved new user playlist '\(playlistName)' with \(addedTracks.count) tracks to storage")
        
        // Leave current screen
        self.goBack()
    }
    
    private func showPlaylistNameEmptyError() {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: Text.value(.Error),
                                 withDescription: Text.value(.ErrorPlaylistNameEmpty))
    }
    
    private func showPlaylistEmptyError() {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: Text.value(.Error),
                                 withDescription: Text.value(.ErrorPlaylistEmpty))
    }
    
    private func showPlaylistAlreadyExistsError() {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: Text.value(.Error),
                                 withDescription: Text.value(.ErrorPlaylistAlreadyExists))
    }
    
    private func showPlaylistUnknownError() {
        AlertWindows.shared.show(sourceVC: self,
                                 withTitle: Text.value(.Error),
                                 withDescription: Text.value(.ErrorUnknown))
    }
}

// Added tracks operations
extension CreateListsViewController {
    private func getAddedTrackAt(_ index: UInt) -> AudioTrack?
    {
        if index < addedTracks.count
        {
            return addedTracks[Int(index)]
        }
        
        return nil
    }
    
    private func addTrackToAddedTracks(fromOpenedAlbumIndex index: UInt)
    {
        if index >= self.openedAlbumTracks.count
        {
            return
        }
        
        let item = self.openedAlbumTracks[Int(index)]
        
        for addedTrack in self.addedTracks
        {
            if item == addedTrack
            {
                return
            }
        }
        
        addedTracks.append(item)
        
        updateAddedTracksView()
    }
    
    private func removeTrackFromAddedTracks(at index: UInt)
    {
        if index >= self.openedAlbumTracks.count
        {
            return
        }
        
        addedTracks.remove(at: Int(index))
        
        updateAddedTracksView()
    }
    
    private func removeTrackFromAddedTracks(withOpenedAlbumIndex index: UInt)
    {
        if index >= self.openedAlbumTracks.count
        {
            return
        }
        
        let openedAlbumTrack = openedAlbumTracks[Int(index)]
        
        addedTracks.removeAll(where: { (element) -> Bool in openedAlbumTrack == element})
        
        updateAddedTracksView()
    }
}

// Album operations
extension CreateListsViewController {
    private func openAlbumAt(index: UInt)
    {
        let selectedAlbum = audioInfoAlbums[Int(index)]
        self.openedAlbum = selectedAlbum
        self.openedAlbumTracks = audioInfo.getAlbumTracks(album: selectedAlbum)
        
        baseView?.openAlbumAt(index: index,
                              albumTracks: openedAlbumTracksAsViewModels,
                              addedTracks: addedTracksAsViewModels)
    }
    
    private func deselectTrackInOpenedAlbum(_ track: CreateListAudioTrack)
    {
        baseView?.deselectTrackFromOpenedAlbum(track)
    }
}
