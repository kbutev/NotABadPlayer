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
    
    func onSearchQuery(_ query: String) {
        
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
    
    func onShowVolumeBarSettingChange(_ value: ShowVolumeBar) {
        if GeneralStorage.shared.getShowVolumeBarValue() == value
        {
            return
        }
        
        Logging.log(SettingsPresenter.self, "App ShowVolumeBar setting changed to \(value.rawValue)")
        
        GeneralStorage.shared.saveShowVolumeBarValue(value)
    }
    
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay) {
        if GeneralStorage.shared.getOpenPlayerOnPlayValue() == value
        {
            return
        }
        
        Logging.log(SettingsPresenter.self, "App OpenPlayerOnPlay setting changed to \(value.rawValue)")
        
        GeneralStorage.shared.saveOpenPlayerOnPlayValue(value)
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
