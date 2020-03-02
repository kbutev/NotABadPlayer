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
    private weak var delegate: BaseViewDelegate?
    
    init() {
        
    }
    
    func setView(_ delegate: BaseViewDelegate) {
        self.delegate = delegate
    }
    
    func start() {
        
    }
    
    func fetchData() {
        
    }
    
    func onAlbumClick(index: UInt) {
        
    }
    
    func onOpenPlayer(playlist: BaseAudioPlaylist) {
        
    }
    
    func contextAudioTrackLyrics() -> String? {
        return nil
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        
    }
    
    func onPlayOrderButtonClick() {
        
    }
    
    func onQuickOpenPlaylistButtonClick() {
        
    }
    
    func onPlayerVolumeSet(value: Double) {
        
    }
    
    func onMarkOrUnmarkContextTrackFavorite() -> Bool {
        return false
    }
    
    func onPlaylistItemClick(index: UInt) {
        
    }
    
    func onPlaylistItemEdit(index: UInt) {
        
    }
    
    func onPlaylistItemDelete(index: UInt) {
        
    }
    
    func onSearchResultClick(index: UInt) {
        
    }
    
    func onSearchQuery(query: String, filterIndex: Int) {
        
    }
    
    func onAppSettingsReset() {
        Logging.log(SettingsPresenter.self, "Settings reset")
        
        GeneralStorage.shared.resetDefaultSettingsValues()
        
        AudioPlayerService.shared.unmute()
        AudioPlayerService.shared.pause()
    }
    
    func onAppThemeChange(_ themeValue: AppThemeValue) {
        if GeneralStorage.shared.getAppThemeValue() == themeValue
        {
            return
        }
        
        Logging.log(SettingsPresenter.self, "App theme changed to \(themeValue.rawValue)")
        
        GeneralStorage.shared.saveAppThemeValue(themeValue)
    }
    
    func onTrackSortingSettingChange(_ trackSorting: TrackSorting) {
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
        
        Logging.log(SettingsPresenter.self, "ShowVolumeBar setting changed, automatically unmuting and pausing player")
        AudioPlayerService.shared.unmute()
        AudioPlayerService.shared.pause()
    }
    
    func onOpenPlayerOnPlaySettingChange(_ value: OpenPlayerOnPlay) {
        if GeneralStorage.shared.getOpenPlayerOnPlayValue() == value
        {
            return
        }
        
        Logging.log(SettingsPresenter.self, "App OpenPlayerOnPlay setting changed to \(value.rawValue)")
        
        GeneralStorage.shared.saveOpenPlayerOnPlayValue(value)
    }
    
    func onKeybindChange(input: ApplicationInput, action: ApplicationAction) {
        if GeneralStorage.shared.getKeybindAction(forInput: input) == action
        {
            return
        }
        
        Logging.log(SettingsPresenter.self, "Keybind changed - map input '\(input.rawValue)' to action '\(action.rawValue)'")
        
        GeneralStorage.shared.saveKeybindAction(action: action, forInput: input)
    }
}
