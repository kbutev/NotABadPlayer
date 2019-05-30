//
//  BaseView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol BaseView : class {
    // General
    func onPlayerSeekChanged(positionInPercentage: Double)
    func onPlayerButtonClick(input: ApplicationInput)
    func onPlayOrderButtonClick()
    func onPlaylistButtonClick()
    
    func goBack()
    func onSwipeUp()
    func onSwipeDown()
    
    // Album
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylist)
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource, actionDelegate: AlbumsViewActionDelegate, albumTitles: [String])
    func onAlbumClick(index: UInt)
    
    // Search
    func searchQueryUpdate(dataSource: SearchViewDataSource, actionDelegate: SearchViewActionDelegate, resultsCount: UInt)
    func onSearchResultClick(index: UInt)
    func setSearchFieldText(_ text: String)
    
    // Settings
    func onThemeSelect(_ value: AppTheme)
    func onTrackSortingSelect(_ value: TrackSorting)
    func onShowVolumeBarSelect(_ value: ShowVolumeBar)
    func onOpenPlayerOnPlaySelect(_ value: OpenPlayerOnPlay)
    func onKeybindSelect(input: ApplicationInput, action: ApplicationAction)
    func onResetSettingsDefaults()
    
    // Playlist
    func onAlbumSongsLoad(name: String,
                          dataSource: PlaylistViewDataSource,
                          actionDelegate: PlaylistViewActionDelegate)
    func onPlaylistSongsLoad(name: String,
                             dataSource: PlaylistViewDataSource,
                             actionDelegate: PlaylistViewActionDelegate)
    func scrollTo(index: UInt)
    func onTrackClicked(index: UInt)
    
    // Player commands
    func openPlayerScreen(playlist: AudioPlaylist)
    func updatePlayerScreen(playlist: AudioPlaylist)
    func onOpenPlaylistButtonClick(audioInfo: AudioInfo)
    func onPlayerErrorEncountered(_ error: Error)
}
