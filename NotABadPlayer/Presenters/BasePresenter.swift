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
    func start()
    
    func onAlbumClick(index: UInt)
    func onPlaylistItemClick(index: UInt)
    
    func onPlayerButtonClick(input: ApplicationInput)
    func onPlayOrderButtonClick()
    
    func onOpenPlaylistButtonClick()
    
    func onSearchResultClick(index: UInt)
    func onSearchQuery(searchValue: String)
    
    func onAppSettingsReset()
    func onAppThemeChange(themeValue: AppTheme);
    func onAppSortingChange(albumSorting: AlbumSorting, trackSorting: TrackSorting)
    func onAppAppearanceChange(showStars: ShowStars, showVolumeBar: ShowVolumeBar)
    func onKeybindChange(action: ApplicationAction, input: ApplicationInput)
}
