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
    func setView(_ view: BaseView)
    
    func start()
    
    func onAlbumClick(index: UInt)
    func onPlaylistItemClick(index: UInt)
    
    func onPlayerButtonClick(input: ApplicationInput)
    func onPlayOrderButtonClick()
    
    func onOpenPlaylistButtonClick()
    
    func onSearchResultClick(index: UInt)
    func onSearchQuery(_ query: String)
    
    func onAppSettingsReset()
    func onAppThemeChange(themeValue: AppTheme);
    func onAppSortingChange(albumSorting: AlbumSorting, trackSorting: TrackSorting)
    func onShowVolumeBarSettingChange(_ value: ShowVolumeBar)
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay)
    func onKeybindChange(action: ApplicationAction, input: ApplicationInput)
}
