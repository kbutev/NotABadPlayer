//
//  BaseViewDelegate.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol BaseViewDelegate : class {
    func goBack()
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylist)
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource?, albumTitles: [String])
    
    func onPlaylistSongsLoad(name: String, dataSource: PlaylistViewDataSource?, playingTrackIndex: UInt?)
    
    func onUserPlaylistsLoad(dataSource: ListsViewDataSource?)
    
    func openPlayerScreen(playlist: AudioPlaylist)
    func updatePlayerScreen(playlist: AudioPlaylist)
    
    func searchQueryResults(query: String, dataSource: SearchViewDataSource?, resultsCount: UInt, searchTip: String?)
    
    func onResetSettingsDefaults()
    func onThemeSelect(_ value: AppTheme)
    func onTrackSortingSelect(_ value: TrackSorting)
    func onShowVolumeBarSelect(_ value: ShowVolumeBar)
    
    func onPlayerErrorEncountered(_ error: Error)
}
