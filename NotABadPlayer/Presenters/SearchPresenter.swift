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
    private var lastSearchFilter: SearchTracksFilter = .Title
    
    required init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
    }
    
    func setView(_ delegate: BaseViewDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        // Restore last search query from storage
        let savedQuery = GeneralStorage.shared.retrieveSearchQuery()
        let savedFilter = GeneralStorage.shared.retrieveSearchQueryFilter()

        if savedQuery.count > 0
        {
            onSearchQuery(query: savedQuery, filterIndex: getSearchIndex(for: savedFilter))
        }
    }
    
    func fetchData() {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        
    }
    
    func onOpenPlayer(playlist: BaseAudioPlaylist) {
        Logging.log(SearchPresenter.self, "Open player screen")
        
        self.delegate?.openPlayerScreen(playlist: playlist)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        let action = Keybinds.shared.getActionFor(input: input)
        
        Logging.log(SearchPresenter.self, "Perform KeyBinds action '\(action.rawValue)' for input '\(input.rawValue)'")
        
        if let error = Keybinds.shared.performAction(action: action)
        {
            delegate?.onPlayerErrorEncountered(error)
        }
    }
    
    func onPlayOrderButtonClick() {
        Logging.log(SearchPresenter.self, "Change audio player play order")
        
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
    
    func onSearchQuery(query: String, filterIndex: Int) {
        guard self.delegate != nil else {
            fatalError("Delegate is not set for \(String(describing: SearchPresenter.self))")
        }
        
        let filter = self.getSearchFilter(for: filterIndex)
        
        // If the query was already made, return
        if let lastQuery = lastSearchQuery
        {
            if query == lastQuery && lastSearchFilter == filter
            {
                return
            }
        }
        
        Logging.log(SearchPresenter.self, "Searching for '\(query)', filter: \(filter.rawValue) ...")
        
        lastSearchQuery = query
        lastSearchFilter = filter
        
        // Save query to storage
        GeneralStorage.shared.saveSearchQuery(query)
        GeneralStorage.shared.saveSearchQueryFilter(filter)
        
        // Start search process
        delegate?.updateSearchQueryResults(query: query,
                                           filterIndex: filterIndex,
                                           dataSource: nil,
                                           resultsCount: 0,
                                           searchTip: "Searching...")
        
        // Use background thread to retrieve the search results
        // Then, update the view on the main thread
        DispatchQueue.global(qos: .background).async {
            let results = self.audioInfo.searchForTracks(query: query, filter: filter)
            self.searchResults = results
            
            let dataSource = SearchViewDataSource(audioInfo: self.audioInfo, searchResults: results)
            self.dataSource = dataSource
            
            DispatchQueue.main.async {
                Logging.log(SearchPresenter.self, "Retrieved search results, updating view")
                
                self.delegate?.updateSearchQueryResults(query: query,
                                                        filterIndex: filterIndex,
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
        
        do {
            var node = AudioPlaylistBuilder.start()
            node.name = playlistName
            node.tracks = searchResults
            node.playingTrack = track
            
            let searchPlaylist = try node.build()
            delegate.openPlayerScreen(playlist: searchPlaylist)
        } catch let e {
            Logging.log(SearchPresenter.self, "Error: cannot open player screen: \(e.localizedDescription)")
        }
    }
    
    private func playNewTrack(_ track: AudioTrack) {
        let player = AudioPlayer.shared
        
        let playlistName = Text.value(.SearchPlaylistName)
        
        var searchPlaylist: BaseAudioPlaylist!
        
        do {
            var node = AudioPlaylistBuilder.start()
            node.name = playlistName
            node.tracks = searchResults
            node.playingTrack = track
            
            searchPlaylist = try node.build()
        } catch let e {
            Logging.log(SearchPresenter.self, "Error: cannot play track: \(e.localizedDescription)")
            return
        }
        
        if let currentPlaylist = player.playlist
        {
            // Current playing playlist or track does not match the state of the presenter's playlist?
            if (!(searchPlaylist.equals(currentPlaylist)))
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
    
    private func playFirstTime(playlist: BaseAudioPlaylist) {
        playNew(playlist: playlist)
    }
    
    private func playNew(playlist: BaseAudioPlaylist) {
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
        
        delegate.updatePlayerScreen(playlist: playlist)
    }
    
    private func getSearchFilter(for index: Int) -> SearchTracksFilter {
        if index == 2 {
            return SearchTracksFilter.Artist
        }
        
        if index == 1 {
            return SearchTracksFilter.Album
        }
        
        return SearchTracksFilter.Title
    }
    
    private func getSearchIndex(for filter: SearchTracksFilter) -> Int {
        if filter == .Artist {
            return 2
        }
        
        if filter == .Album {
            return 1
        }
        
        return 0
    }
}
