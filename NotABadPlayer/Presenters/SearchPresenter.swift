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
    
    var searchResults: [BaseAudioTrack] {
        get {
            var value: [BaseAudioTrack] = []
            
            performOnMain {
                value = self._searchResults
            }
            
            return value
        }
        set {
            performOnMain {
                self._searchResults = newValue
            }
        }
    }
    
    private var _searchResults: [BaseAudioTrack] = []
    
    private var dataSource: SearchViewDataSource?
    
    private var lastSearchQuery: String?
    private var lastSearchFilter: SearchTracksFilter = .Title
    
    private let restoreLastSearch: Bool
    
    init(audioInfo: AudioInfo, restoreLastSearch:Bool=true) {
        self.audioInfo = audioInfo
        self.restoreLastSearch = restoreLastSearch
    }
    
    func setView(_ delegate: BaseViewDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        if !self.restoreLastSearch {
            return
        }
        
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
    
    func onOpenPlayer(playlist: BaseAudioPlaylist) {
        Logging.log(SearchPresenter.self, "Open player screen")
        
        self.delegate?.openPlayerScreen(playlist: playlist)
    }
    
    func contextAudioTrackLyrics() -> String? {
        return nil
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
    
    func onQuickOpenPlaylistButtonClick() {
        if let playlist = AudioPlayerService.shared.playlist
        {
            delegate?.openPlaylistScreen(audioInfo: audioInfo, playlist: playlist, options: OpenPlaylistOptions.buildDefault())
        }
    }
    
    func onPlayerVolumeSet(value: Double) {
        
    }
    
    func onMarkOrUnmarkContextTrackFavorite() -> Bool {
        return false
    }
    
    func onPlaylistItemClick(index: UInt) {
        
    }
    
    func onPlaylistItemEdit(index: UInt) {
        
    }
    
    func onPlaylistItemDelete(index: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        let results = searchResults
        
        if index >= results.count
        {
            return
        }
        
        let clickedTrack = results[Int(index)]
        
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
        delegate?.onSearchQueryBegin()
        
        // Use background thread to retrieve the search results
        // Then, update the view on the main thread
        DispatchQueue.global(qos: .background).async {
            let results = self.audioInfo.searchForTracks(query: query, filter: filter)
            self.searchResults = results
            
            DispatchQueue.main.async {
                Logging.log(SearchPresenter.self, "Retrieved search results, updating view")
                
                let dataSource = SearchViewDataSource(audioInfo: self.audioInfo, searchResults: results)
                self.dataSource = dataSource
                
                self.delegate?.updateSearchQueryResults(query: query,
                                                        filterIndex: filterIndex,
                                                        dataSource: dataSource,
                                                        resultsCount: UInt(results.count))
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
    
    private func openPlayerScreen(_ track: BaseAudioTrack) {
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
    
    private func playNewTrack(_ track: BaseAudioTrack) {
        let player = AudioPlayerService.shared
        
        let playlistName = Text.value(.SearchPlaylistName)
        let tracks = self.searchResults
        
        var searchPlaylist: BaseAudioPlaylist!
        
        do {
            var node = AudioPlaylistBuilder.start()
            node.name = playlistName
            node.tracks = tracks
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
        
        let player = AudioPlayerService.shared
        
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

// Utilities
extension SearchPresenter {
    func performOnMain(_ callback: () -> Void) {
        if Thread.isMainThread {
            callback()
        } else {
            DispatchQueue.main.sync {
                callback()
            }
        }
    }
}
