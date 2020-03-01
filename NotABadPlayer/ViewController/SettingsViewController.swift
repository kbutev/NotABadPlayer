//
//  SettingsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, BaseViewDelegate {
    private var baseView: SettingsView?
    
    private let presenter: BasePresenter?
    
    private let rootView: BaseViewDelegate?
    
    init(presenter: BasePresenter, rootView: BaseViewDelegate?) {
        self.presenter = presenter
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.presenter = nil
        self.rootView = nil
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = SettingsView.create(owner: self)
        self.view = self.baseView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        presenter?.start()
        
        baseView?.delegate = self
        
        selectDefaultPickerValues()
    }
    
    private func setup() {
        baseView?.onAppThemeSelectCallback = {[weak self] (value) in
            self?.presenter?.onAppThemeChange(value)
        }
        
        baseView?.onTrackSortingSelectCallback = {[weak self] (value) in
            self?.presenter?.onTrackSortingSettingChange(value)
        }
        
        baseView?.onShowVolumeBarSelectCallback = {[weak self] (value) in
            self?.presenter?.onShowVolumeBarSettingChange(value)
        }
        
        baseView?.onOpenPlayerOnPlaySelectCallback = {[weak self] (value) in
            self?.presenter?.onOpenPlayerOnPlaySettingChange(value)
        }
        
        baseView?.onKeybindSelectCallback = {[weak self] (input, action) in
            self?.presenter?.onKeybindChange(input: input, action: action)
        }
        
        let resetSettingsDefaultsAction = {[weak self] (action:UIAlertAction) in
            self?.presenter?.onAppSettingsReset()
            self?.selectDefaultPickerValues()
        }
        
        baseView?.onResetSettingsDefaults = {[weak self] () in
            if let vc = self
            {
                AlertWindows.shared.show(sourceVC: vc, withTitle: "", withDescription: "Reset settings to defaults?",
                                         actionLeftText: "NO", actionLeft: nil,
                                         actionRightText: "YES", actionRight: resetSettingsDefaultsAction)
            }
        }
    }
    
    private func selectDefaultPickerValues() {
        let storage = GeneralStorage.shared
        
        baseView?.selectTheme(storage.getAppThemeValue())
        baseView?.selectTrackSorting(storage.getTrackSortingValue())
        baseView?.selectOpenPlayerOnPlay(storage.getOpenPlayerOnPlayValue())
        
        var input: ApplicationInput = .PLAYER_RECALL
        
        input = .PLAYER_RECALL
        baseView?.selectKeybind(keybind: input, action: storage.getKeybindAction(forInput: input))
        
        input = .PLAYER_PREVIOUS_BUTTON
        baseView?.selectKeybind(keybind: input, action: storage.getKeybindAction(forInput: input))
        
        input = .PLAYER_NEXT_BUTTON
        baseView?.selectKeybind(keybind: input, action: storage.getKeybindAction(forInput: input))
        
        input = .PLAYER_SWIPE_LEFT
        baseView?.selectKeybind(keybind: input, action: storage.getKeybindAction(forInput: input))
        
        input = .PLAYER_SWIPE_RIGHT
        baseView?.selectKeybind(keybind: input, action: storage.getKeybindAction(forInput: input))
        
        input = .QUICK_PLAYER_PREVIOUS_BUTTON
        baseView?.selectKeybind(keybind: input, action: storage.getKeybindAction(forInput: input))
        
        input = .QUICK_PLAYER_NEXT_BUTTON
        baseView?.selectKeybind(keybind: input, action: storage.getKeybindAction(forInput: input))
        
        input = .LOCK_PLAYER_PREVIOUS_BUTTON
        baseView?.selectKeybind(keybind: input, action: storage.getKeybindAction(forInput: input))
        
        input = .LOCK_PLAYER_NEXT_BUTTON
        baseView?.selectKeybind(keybind: input, action: storage.getKeybindAction(forInput: input))
    }
    
    func goBack() {
        
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: BaseAudioPlaylist, options: OpenPlaylistOptions) {
        
    }
    
    func onMediaAlbumsLoad(dataSource: BaseAlbumsViewDataSource?, albumTitles: [String]) {
        
    }
    
    func onPlaylistSongsLoad(name: String, dataSource: BasePlaylistViewDataSource?, playingTrackIndex: UInt?) {
        
    }
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: BaseListsViewDataSource?) {
        
    }
    
    func openPlayerScreen(playlist: BaseAudioPlaylist) {
        
    }
    
    func updatePlayerScreen(playlist: BaseAudioPlaylist) {
        
    }
    
    func onSearchQueryBegin() {
        
    }
    
    func updateSearchQueryResults(query: String, filterIndex: Int, dataSource: BaseSearchViewDataSource?, resultsCount: UInt) {
        
    }
    
    func onResetSettingsDefaults() {
        
    }
    
    func onThemeSelect(_ value: AppThemeValue) {
        
    }
    
    func onTrackSortingSelect(_ value: TrackSorting) {
        
    }
    
    func onShowVolumeBarSelect(_ value: ShowVolumeBar) {
        
    }
    
    func onAudioLibraryChanged() {
        
    }
    
    func onFetchDataErrorEncountered(_ error: Error) {
        // Fetch data again until successful
        presenter?.fetchData()
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        
    }
}
