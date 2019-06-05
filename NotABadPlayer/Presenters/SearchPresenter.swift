//
//  SearchPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 29.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class SearchPresenter: BasePresenter
{
    private weak var delegate: BaseViewDelegate?
    
    private let audioInfo: AudioInfo
    
    private var searchResults: [AudioTrack] = []
    
    private var dataSource: SearchViewDataSource?
    
    private var lastSearchQuery: String?
    
    required init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
    }
    
    func setView(_ delegate: BaseViewDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        // Restore last search query from storage
        let savedQuery = GeneralStorage.shared.retrieveSearchQuery()

        if savedQuery.count > 0
        {
            onSearchQuery(savedQuery)
        }
    }
    
    func onAppStateChange(state: AppState) {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        
    }
    
    func onOpenPlayer(playlist: AudioPlaylist) {
        Logging.log(SearchPresenter.self, "Open player screen")
        
        self.delegate?.openPlayerScreen(playlist: playlist)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(SearchPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        let _ = Keybinds.shared.performAction(action: action)
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(SearchPresenter.self, "Change audio player play order")
        
        let _ = Keybinds.shared.performAction(action: .CHANGE_PLAY_ORDER)
    }
    
    func onOpenPlaylistButtonClick() {
        if let playlist = AudioPlayer.shared.playlist
        {
            delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist)
        }
    }
    
    func onPlayerVolumeSet(value: Double) {
        
    }
    
    func onPlaylistsChanged() {
        
    }
    
    func onPlaylistItemDelete(index: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        if index >= searchResults.count
        {
            return
        }
        
        let clickedTrack = searchResults[Int(index)]
        
        if GeneralStorage.shared.getOpenPlayerOnPlayValue().openForSearch()
        {
            openPlayerScreen(clickedTrack)
        }
        else
        {
            playNewTrack(clickedTrack)
        }
    }
    
    func onSearchQuery(_ query: String) {
        guard self.delegate != nil else {
            fatalError("Delegate is not set for \(String(describing: SearchPresenter.self))")
        }
        
        // If the query was already made, return
        if let lastQuery = lastSearchQuery
        {
            if query == lastQuery
            {
                return
            }
        }
        
        lastSearchQuery = query
        
        Logging.log(SearchPresenter.self, "Searching for tracks by query '\(query)'")
        
        // Save query to storage
        GeneralStorage.shared.saveSearchQuery(query)
        
        // Start search process
        delegate?.searchQueryResults(query: query, dataSource: nil, resultsCount: 0, searchTip: "Searching...")
        
        // Use background thread to retrieve the search results
        // Then, update the view on the main thread
        DispatchQueue.global(qos: .background).async {
            let results = self.audioInfo.searchForTracks(query: query)
            self.searchResults = results
            
            let dataSource = SearchViewDataSource(audioInfo: self.audioInfo, searchResults: results)
            self.dataSource = dataSource
            
            DispatchQueue.main.async {
                self.delegate?.searchQueryResults(query: query,
                                                  dataSource: dataSource,
                                                  resultsCount: UInt(results.count),
                                                  searchTip: nil)
            }
        }
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
    
    private func openPlayerScreen(_ track: AudioTrack) {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: SearchPresenter.self))")
        }
        
        Logging.log(SearchPresenter.self, "Opening player screen")
        
        let playlistName = Text.value(.SearchPlaylistName)
        let searchPlaylist = AudioPlaylist(name: playlistName, tracks: searchResults, startWithTrack: track)
        
        delegate.openPlayerScreen(playlist: searchPlaylist)
    }
    
    private func playNewTrack(_ track: AudioTrack) {
        let player = AudioPlayer.shared
        
        let playlistName = Text.value(.SearchPlaylistName)
        let searchPlaylist = AudioPlaylist(name: playlistName, tracks: searchResults, startWithTrack: track)
        
        if let currentPlaylist = player.playlist
        {
            // Current playing playlist or track does not match the state of the presenter's playlist?
            if (searchPlaylist.name != currentPlaylist.name || searchPlaylist.playingTrack != currentPlaylist.playingTrack)
            {
                // Change the audio player playlist to equal the presenter's playlist
                Logging.log(SearchPresenter.self, "Playing track '\(searchPlaylist.playingTrack.title)' from playlist '\(searchPlaylist.name)'")
                playNew(playlist: searchPlaylist)
                
                return
            }
            
            // Do nothing, track is already playing
            
            return
        }
        
        // Set audio player playlist for the first time and play its track
        Logging.log(SearchPresenter.self, "Playing track '\(searchPlaylist.playingTrack.title)' from playlist '\(searchPlaylist.name)' for the first time")
        playFirstTime(playlist: searchPlaylist)
    }
    
    private func playFirstTime(playlist: AudioPlaylist) {
        playNew(playlist: playlist)
    }
    
    private func playNew(playlist: AudioPlaylist) {
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: PlaylistPresenter.self))")
        }
        
        let player = AudioPlayer.shared
        
        do {
            try player.play(playlist: playlist)
        } catch let e {
            delegate.onPlayerErrorEncountered(e)
        }
        
        if !player.isPlaying
        {
            player.resume()
        }
    }
}