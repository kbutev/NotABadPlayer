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
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: BaseAudioPlaylist)
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource?, albumTitles: [String])
    
    func onPlaylistSongsLoad(name: String, dataSource: PlaylistViewDataSource?, playingTrackIndex: UInt?)
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: BaseListsViewDataSource?)
    
    func openPlayerScreen(playlist: BaseAudioPlaylist)
    func updatePlayerScreen(playlist: BaseAudioPlaylist)
    
    func updateSearchQueryResults(query: String, filterIndex: Int, dataSource: SearchViewDataSource?, resultsCount: UInt, searchTip: String?)
    
    func onResetSettingsDefaults()
    func onThemeSelect(_ value: AppThemeValue)
    func onTrackSortingSelect(_ value: TrackSorting)
    func onShowVolumeBarSelect(_ value: ShowVolumeBar)
    
    func onFetchDataErrorEncountered(_ error: Error)
    func onPlayerErrorEncountered(_ error: Error)
}
