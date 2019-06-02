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
    
    func onAppStateChange(state: AppState)
    
    func onAlbumClick(index: UInt)
    func onPlaylistItemClick(index: UInt)
    
    func onOpenPlayer(playlist: AudioPlaylist)
    
    func onPlayerButtonClick(input: ApplicationInput)
    func onPlayOrderButtonClick()
    func onOpenPlaylistButtonClick()
    
    func onPlaylistItemDelete(index: UInt)
    
    func onSearchResultClick(index: UInt)
    func onSearchQuery(_ query: String)
    
    func onAppSettingsReset()
    func onAppThemeChange(_ themeValue: AppTheme);
    func onTrackSortingSettingChange(_ trackSorting: TrackSorting)
    func onShowVolumeBarSettingChange(_ value: ShowVolumeBar)
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay)
    func onKeybindChange(input: ApplicationInput, action: ApplicationAction)
}
