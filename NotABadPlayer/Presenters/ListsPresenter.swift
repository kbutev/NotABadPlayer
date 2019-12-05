//
//  ListsPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

enum ListsPresenterError: Error {
    case failedToBuildMutableList(String)
}

class ListsPresenter: BasePresenter
{
    private weak var delegate: BaseViewDelegate?
    
    private let audioInfo: AudioInfo
    
    private var playlists: [BaseAudioPlaylist] = []
    
    private var collectionDataSource: ListsViewDataSource?
    
    required init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
    }
    
    func setView(_ delegate: BaseViewDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        fetchData()
    }
    
    func fetchData() {
        Logging.log(ListsPresenter.self, "Retrieving user playlists...")
        
        // Perform work on background thread
        DispatchQueue.global().async {
            var playlists = GeneralStorage.shared.getUserPlaylists()
            
            let playlistsCount = playlists.count
            
            let recentlyAddedTracks = self.audioInfo.recentlyAddedTracks()
            
            if recentlyAddedTracks.count > 0
            {
                var node = AudioPlaylistBuilder.start()
                node.name = Text.value(.PlaylistRecentlyAdded)
                node.tracks = recentlyAddedTracks
                node.isTemporary = true
                
                do {
                    playlists.insert(try node.buildMutable(), at: 0)
                } catch {
                    
                }
            }
            
            let recentlyPlayedTracks = AudioPlayer.shared.playHistory
            
            if recentlyPlayedTracks.count > 0
            {
                var node = AudioPlaylistBuilder.start()
                node.name = Text.value(.PlaylistRecentlyPlayed)
                node.tracks = recentlyPlayedTracks
                node.isTemporary = true
                
                do {
                    playlists.insert(try node.buildMutable(), at: 0)
                } catch {
                    
                }
            }
            
            // Then, update on main thread
            DispatchQueue.main.async {
                Logging.log(ListsPresenter.self, "Retrieved \(playlistsCount) user playlists, updating view")
                
                self.playlists = playlists
                self.collectionDataSource = ListsViewDataSource(audioInfo: self.audioInfo, playlists: self.playlists)
                
                self.delegate?.onUserPlaylistsLoad(audioInfo: self.audioInfo, dataSource: self.collectionDataSource)
            }
        }
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        
        if index >= self.playlists.count
        {
            return
        }
        
        let playlist = self.playlists[Int(index)]
        
        Logging.log(ListsPresenter.self, "Open playlist screen for playlist \(playlist.name)")
        
        self.delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
    }
    
    func onOpenPlayer(playlist: BaseAudioPlaylist) {
        Logging.log(ListsPresenter.self, "Open player screen")
        
        self.delegate?.openPlayerScreen(playlist: playlist)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(ListsPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        if let error = Keybinds.shared.performAction(action: action)
        {
            delegate?.onPlayerErrorEncountered(error)
        }
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(ListsPresenter.self, "Change audio player play order")
        
        if let error = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
        {
            delegate?.onPlayerErrorEncountered(error)
        }
    }
    
    func onOpenPlaylistButtonClick() {
        if let playlist = AudioPlayer.shared.playlist
        {
            delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
        }
    }
    
    func onPlayerVolumeSet(value: Double) {
        
    }
    
    func onPlaylistItemDelete(index: UInt) {
        if index >= self.playlists.count
        {
            return
        }
        
        if !shouldDeletePlaylistAt(index: index)
        {
            return
        }
        
        let playlistToDelete = self.playlists[Int(index)]
        
        self.playlists.remove(at: Int(index))
        
        // Save
        do {
            let playlistsToSave = try buildMutablePlaylistsFromCurrentData(ignoreTemporary: true)
            GeneralStorage.shared.saveUserPlaylists(playlistsToSave)
        } catch {
            Logging.log(ListsPresenter.self, "Failed to delete user playlist '\(playlistToDelete.name)' from storage, unknown error")
            return
        }
        
        Logging.log(ListsPresenter.self, "Deleted user playlist '\(playlistToDelete.name)' from storage")
        
        // Update data source
        updateDataSource()
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(query: String, filterIndex: Int) {
        
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
    
    private func updateDataSource() {
        self.collectionDataSource = ListsViewDataSource(audioInfo: audioInfo, playlists: playlists)
        
        delegate?.onUserPlaylistsLoad(audioInfo: audioInfo, dataSource: collectionDataSource)
    }
    
    private func shouldDeletePlaylistAt(index: UInt) -> Bool {
        // Do not delete temporary playlists, as they are recently played/added playlists
        return !self.playlists[Int(index)].isTemporary
    }
    
    private func buildMutablePlaylistsFromCurrentData(ignoreTemporary: Bool) throws -> [MutableAudioPlaylist] {
        // Do not save temporary playlists, as they are recently played/added playlists
        var playlists: [MutableAudioPlaylist] = []
        
        for playlist in self.playlists
        {
            if !ignoreTemporary || !playlist.isTemporary
            {
                do {
                    let node = AudioPlaylistBuilder.start(prototype: playlist)
                    playlists.append(try node.buildMutable())
                } catch {
                    throw ListsPresenterError.failedToBuildMutableList("Failed to build")
                }
            }
        }
        
        return playlists
    }
}
