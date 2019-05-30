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
    private weak var delegate: BaseView?
    
    private let audioInfo: AudioInfo
    
    private var searchResults: [AudioTrack] = []
    
    private var collectionDataSource: SearchViewDataSource?
    private var collectionActionDelegate: SearchViewActionDelegate?
    
    required init(audioInfo: AudioInfo) {
        self.audioInfo = audioInfo
    }
    
    func setView(_ view: BaseView) {
        self.delegate = view
    }
    
    func start() {
        // Restored state
        let savedQuery = GeneralStorage.shared.retrieveSearchQuery()
        
        if savedQuery.count > 0
        {
            onSearchQuery(savedQuery)
            delegate?.setSearchFieldText(savedQuery)
        }
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        
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
        delegate?.onOpenPlaylistButtonClick(audioInfo: audioInfo)
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
        guard let delegate = self.delegate else {
            fatalError("Delegate is not set for \(String(describing: SearchPresenter.self))")
        }
        
        Logging.log(SearchPresenter.self, "Searching for tracks by query '\(query)'")
        
        self.searchResults = audioInfo.searchForTracks(query: query)
        
        let dataSource = SearchViewDataSource(audioInfo: audioInfo, searchResults: searchResults)
        self.collectionDataSource = dataSource
        
        let actionDelegate = SearchViewActionDelegate(view: delegate)
        self.collectionActionDelegate = actionDelegate
        
        delegate.searchQueryUpdate(dataSource: dataSource, actionDelegate: actionDelegate, resultsCount: UInt(searchResults.count))
        
        GeneralStorage.shared.saveSearchQuery(query)
    }
    
    func onAppSettingsReset() {
        
    }
    
    func onAppThemeChange(themeValue: AppTheme) {
        
    }
    
    func onAppSortingChange(albumSorting: AlbumSorting, trackSorting: TrackSorting) {
        
    }
    
    func onShowVolumeBarSettingChange(_ value: ShowVolumeBar) {
        
    }
    
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay) {
        
    }
    
    func onKeybindChange(action: ApplicationAction, input: ApplicationInput) {
        
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
