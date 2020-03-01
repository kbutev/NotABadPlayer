//
//  CreateListsPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 22.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol BaseCreateListsPresenterDelegate: BaseViewDelegate {
    var onOpenedAlbumTrackSelectionCallback: (UInt)->Void { get }
    var onOpenedAlbumTrackDeselectionCallback: (UInt)->Void { get }
    
    // Added tracks operations
    func updateAddedTracksDataSource(_ dataSource: BaseCreateListAddedTracksTableDataSource?)
    func updateAlbumsDataSource(_ dataSource: BaseCreateListViewAlbumsDataSource?)
    func deselectAddedTrack(_ track: CreateListAudioTrack)
    
    // Album track operations
    func openAlbumAt(index: UInt, albumTracks: [CreateListAudioTrack], addedTracks: [CreateListAudioTrack])
    
    // Search operations
    func onSearchResultClick(index: UInt)
    
    func showPlaylistNameEmptyError()
    func showPlaylistEmptyError()
    func showPlaylistAlreadyExistsError()
    func showPlaylistUnknownError()
}

protocol BaseCreateListsPresenter: BasePresenter {
    func updateAddedTracksView()
    func updateAlbumsView()
    
    func onPlaylistNameChanged(_ name: String)
    
    // Flow
    func onSaveUserPlaylist()
    
    // Added tracks operations
    func isTrackAdded(_ track: BaseAudioTrack) -> Bool
    func onAddedTrackClicked(at index: UInt)
    
    // Album track operations
    func openAlbumAt(index: UInt)
    func onAlbumTrackSelect(fromOpenedAlbumIndex index: UInt)
    func onAlbumTrackDeselect(withOpenedAlbumIndex index: UInt)
}

class CreateListsPresenter: BaseCreateListsPresenter {
    private weak var delegate: BaseCreateListsPresenterDelegate?
    
    private let searchPresenter: SearchPresenter
    
    private let audioInfo: AudioInfo!
    private var audioInfoAlbums: [AudioAlbum] = []
    private var addedTracks: [BaseAudioTrack] = []
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
    private var openedAlbumTracks: [BaseAudioTrack] = []
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
    
    private var addedTracksTableDataSource: BaseCreateListAddedTracksTableDataSource?
    private var albumsDataSource: BaseCreateListViewAlbumsDataSource?
    
    init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
        self.searchPresenter = SearchPresenter(audioInfo: audioInfo, restoreLastSearch: false)
    }
    
    func updateAddedTracksView() {
        self.addedTracksTableDataSource = CreateListAddedTracksTableDataSource(audioInfo: audioInfo, tracks: addedTracks)
        
        delegate?.updateAddedTracksDataSource(self.addedTracksTableDataSource)
    }
    
    func updateAlbumsView() {
        guard let view = delegate else {
            return
        }
        
        let onOpenedAlbumTrackSelectionCallback = view.onOpenedAlbumTrackSelectionCallback
        let onOpenedAlbumTrackDeselectionCallback = view.onOpenedAlbumTrackDeselectionCallback
        
        self.albumsDataSource = CreateListPickAlbumTracksDataSource(albums: self.audioInfoAlbums,
                                                                    onOpenedAlbumTrackSelectionCallback: onOpenedAlbumTrackSelectionCallback,
                                                                    onOpenedAlbumTrackDeselectionCallback: onOpenedAlbumTrackDeselectionCallback)
        
        delegate?.updateAlbumsDataSource(self.albumsDataSource)
    }
    
    func onPlaylistNameChanged(_ name: String) {
        if name.count < CreateListsViewController.PLAYLIST_NAME_LENGTH_LIMIT
        {
            self.playlistName = name
        }
        else
        {
            self.playlistName = String(name.prefix(CreateListsViewController.PLAYLIST_NAME_LENGTH_LIMIT))
        }
    }
    
    // Flow
    
    func onSaveUserPlaylist() {
        if playlistName.count == 0
        {
            delegate?.showPlaylistNameEmptyError()
            return
        }
        
        if addedTracks.count == 0
        {
            delegate?.showPlaylistEmptyError()
            return
        }
        
        var storagePlaylists = GeneralStorage.shared.getUserPlaylists()
        
        for storagePlaylist in storagePlaylists
        {
            if playlistName == storagePlaylist.name
            {
                delegate?.showPlaylistAlreadyExistsError()
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
            Logging.log(CreateListsPresenter.self, "Failed to save user playlist '\(playlistName)' with \(addedTracks.count) tracks to storage, failed to build playlist")
            delegate?.showPlaylistUnknownError()
            return
        }
        
        // Save
        GeneralStorage.shared.saveUserPlaylists(storagePlaylists)
        
        Logging.log(CreateListsPresenter.self, "Saved new user playlist '\(playlistName)' with \(addedTracks.count) tracks to storage")
        
        // Leave current screen
        delegate?.goBack()
    }
    
    // Added tracks operations
    
    func isTrackAdded(_ track: BaseAudioTrack) -> Bool {
        for addedTrack in self.addedTracks
        {
            if track == addedTrack
            {
                return true
            }
        }
        
        return false
    }
    
    func onAddedTrackClicked(at index: UInt) {
        let trackValue = getAddedTrack(at: index)
        
        removeTrackFromAddedTracks(at: index)
        
        if let track = trackValue
        {
            let listTrack = CreateListAudioTrack.createFrom(track)
            
            delegate?.deselectAddedTrack(listTrack)
        }
    }
    
    func removeTrackFromAddedTracks(at index: UInt)
    {
        if index >= self.addedTracks.count
        {
            return
        }
        
        addedTracks.remove(at: Int(index))
        
        updateAddedTracksView()
    }
    
    // Album tracks operations
    
    func openAlbumAt(index: UInt)
    {
        let selectedAlbum = audioInfoAlbums[Int(index)]
        self.openedAlbum = selectedAlbum
        self.openedAlbumTracks = audioInfo.getAlbumTracks(album: selectedAlbum)
        
        delegate?.openAlbumAt(index: index,
                              albumTracks: openedAlbumTracksAsViewModels,
                              addedTracks: addedTracksAsViewModels)
    }
    
    func onAlbumTrackSelect(fromOpenedAlbumIndex index: UInt)
    {
        if index >= self.openedAlbumTracks.count
        {
            return
        }
        
        let item = self.openedAlbumTracks[Int(index)]
        
        if isTrackAdded(item)
        {
            return
        }
        
        addedTracks.append(item)
        
        updateAddedTracksView()
    }
    
    func onAlbumTrackDeselect(withOpenedAlbumIndex index: UInt)
    {
        if index >= self.openedAlbumTracks.count
        {
            return
        }
        
        let openedAlbumTrack = openedAlbumTracks[Int(index)]
        
        addedTracks.removeAll(where: { (element) -> Bool in openedAlbumTrack == element})
        
        updateAddedTracksView()
    }
    
    // Base presenter
    
    func setView(_ delegate: BaseViewDelegate) {
        self.delegate = delegate as? BaseCreateListsPresenterDelegate
        
        self.searchPresenter.setView(delegate)
    }
    
    func start() {
        self.audioInfoAlbums = audioInfo?.getAlbums() ?? []
        
        self.searchPresenter.start()
    }
    
    func fetchData() {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        
    }
    
    func onOpenPlayer(playlist: BaseAudioPlaylist) {
        
    }
    
    func contextAudioTrackLyrics() -> String? {
        return nil
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        
    }
    
    func onPlayOrderButtonClick() {
        
    }
    
    func onQuickOpenPlaylistButtonClick() {
        
    }
    
    func onPlayerVolumeSet(value: Double) {
        
    }
    
    func onMarkOrUnmarkContextTrackFavorite() -> Bool {
        return false
    }
    
    func onPlaylistItemDelete(index: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        let results = searchPresenter.searchResults
        
        if index >= results.count {
            return
        }
        
        defer {
            delegate?.onSearchResultClick(index: index)
            updateAddedTracksView()
        }
        
        let item = results[Int(index)]
        
        if isTrackAdded(item)
        {
            removeSearchResult(at: index)
            return
        }
        
        addedTracks.append(item)
    }
    
    func onSearchQuery(query: String, filterIndex: Int) {
        self.searchPresenter.onSearchQuery(query: query, filterIndex: filterIndex)
    }
    
    func onAppSettingsReset() {
        
    }
    
    func onAppThemeChange(_ themeValue: AppThemeValue) {
        
    }
    
    func onTrackSortingSettingChange(_ trackSorting: TrackSorting) {
        
    }
    
    func onShowVolumeBarSettingChange(_ value: ShowVolumeBar) {
        
    }
    
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay) {
        
    }
    
    func onKeybindChange(input: ApplicationInput, action: ApplicationAction) {
        
    }
}

// Utilities
extension CreateListsPresenter {
    private func getAddedTrack(at index: UInt) -> BaseAudioTrack?
    {
        if index < addedTracks.count
        {
            return addedTracks[Int(index)]
        }
        
        return nil
    }
    
    private func removeSearchResult(at index: UInt) {
        let results = searchPresenter.searchResults
        
        if index >= results.count
        {
            return
        }
        
        let item = results[Int(index)]
        
        addedTracks.removeAll { (element) -> Bool in
            return element == item
        }
    }
}
