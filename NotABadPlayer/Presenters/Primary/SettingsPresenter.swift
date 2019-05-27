//
//  SettingsPresenter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 27.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class SettingsPresenter: BasePresenter
{
    public weak var delegate: SettingsViewDelegate?
    
    required init(view: SettingsViewDelegate?=nil) {
        self.delegate = view
    }
    
    func start() {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onPlaylistItemClick(index: UInt) {
        
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        
    }
    
    func onPlayOrderButtonClick() {
        
    }
    
    func onOpenPlaylistButtonClick() {
        
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(searchValue: String) {
        
    }
    
    func onAppSettingsReset() {
        Logging.log(SettingsPresenter.self, "Settings reset")
        
        GeneralStorage.shared.resetDefaultSettingsValues()
    }
    
    func onAppThemeChange(themeValue: AppTheme) {
        if GeneralStorage.shared.getAppThemeValue() == themeValue
        {
            return
        }
        
        Logging.log(SettingsPresenter.self, "App theme changed to \(themeValue.rawValue)")
        
        GeneralStorage.shared.saveAppThemeValue(themeValue)
    }
    
    func onAppSortingChange(albumSorting: AlbumSorting, trackSorting: TrackSorting) {
        if GeneralStorage.shared.getTrackSortingValue() == trackSorting
        {
            return
        }
        
        Logging.log(SettingsPresenter.self, "App track sorting changed to \(trackSorting.rawValue)")
        
        GeneralStorage.shared.saveTrackSortingValue(trackSorting)
    }
    
    func onAppAppearanceChange(showStars: ShowStars, showVolumeBar: ShowVolumeBar) {
        if GeneralStorage.shared.getShowVolumeBarValue() == showVolumeBar
        {
            return
        }
        
        Logging.log(SettingsPresenter.self, "App show volume bar setting changed to \(showVolumeBar.rawValue)")
        
        GeneralStorage.shared.saveShowVolumeBarValue(showVolumeBar)
    }
    
    func onKeybindChange(action: ApplicationAction, input: ApplicationInput) {
        if GeneralStorage.shared.getSettingsAction(forInput: input) == action
        {
            return
        }
        
        Logging.log(SettingsPresenter.self, "Map keybind input '\(input.rawValue)' to action '\(action.rawValue)'")
        
        GeneralStorage.shared.saveSettingsAction(action: action, forInput: input)
    }
}
