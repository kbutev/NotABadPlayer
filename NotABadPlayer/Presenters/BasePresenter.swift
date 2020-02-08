//
//  Presenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 30.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol BasePresenter
{
    func setView(_ delegate: BaseViewDelegate)
    
    func start()
    
    func fetchData()
    
    func onAlbumClick(index: UInt)
    func onPlaylistItemClick(index: UInt)
    
    func onOpenPlayer(playlist: BaseAudioPlaylist)
    
    func contextAudioTrackLyrics() -> String?
    func onPlayerButtonClick(input: ApplicationInput)
    func onPlayOrderButtonClick()
    func onOpenPlaylistButtonClick()
    func onPlayerVolumeSet(value: Double)
    func onMarkOrUnmarkContextTrackFavorite() -> Bool
    
    func onPlaylistItemDelete(index: UInt)
    
    func onSearchResultClick(index: UInt)
    func onSearchQuery(query: String, filterIndex: Int)
    
    func onAppSettingsReset()
    func onAppThemeChange(_ themeValue: AppThemeValue);
    func onTrackSortingSettingChange(_ trackSorting: TrackSorting)
    func onShowVolumeBarSettingChange(_ value: ShowVolumeBar)
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay)
    func onKeybindChange(input: ApplicationInput, action: ApplicationAction)
}
