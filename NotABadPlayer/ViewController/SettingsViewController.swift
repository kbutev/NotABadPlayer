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
        baseView?.selectTheme(GeneralStorage.shared.getAppThemeValue())
        baseView?.selectTrackSorting(GeneralStorage.shared.getTrackSortingValue())
        baseView?.selectShowVolumeBar(GeneralStorage.shared.getShowVolumeBarValue())
        baseView?.selectOpenPlayerOnPlay(GeneralStorage.shared.getOpenPlayerOnPlayValue())
        
        baseView?.selectKeybind(keybind: .PLAYER_VOLUME_UP_BUTTON,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .PLAYER_VOLUME_UP_BUTTON))
        baseView?.selectKeybind(keybind: .PLAYER_VOLUME_DOWN_BUTTON,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .PLAYER_VOLUME_DOWN_BUTTON))
        baseView?.selectKeybind(keybind: .PLAYER_RECALL,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .PLAYER_RECALL))
        baseView?.selectKeybind(keybind: .PLAYER_PREVIOUS_BUTTON,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .PLAYER_PREVIOUS_BUTTON))
        baseView?.selectKeybind(keybind: .PLAYER_NEXT_BUTTON,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .PLAYER_NEXT_BUTTON))
        baseView?.selectKeybind(keybind: .PLAYER_SWIPE_LEFT,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .PLAYER_SWIPE_LEFT))
        baseView?.selectKeybind(keybind: .PLAYER_SWIPE_RIGHT,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .PLAYER_SWIPE_RIGHT))
        baseView?.selectKeybind(keybind: .QUICK_PLAYER_VOLUME_UP_BUTTON,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .QUICK_PLAYER_VOLUME_UP_BUTTON))
        baseView?.selectKeybind(keybind: .QUICK_PLAYER_VOLUME_DOWN_BUTTON,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .QUICK_PLAYER_VOLUME_DOWN_BUTTON))
        baseView?.selectKeybind(keybind: .QUICK_PLAYER_PREVIOUS_BUTTON,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .QUICK_PLAYER_PREVIOUS_BUTTON))
        baseView?.selectKeybind(keybind: .QUICK_PLAYER_NEXT_BUTTON,
                                action: GeneralStorage.shared.getSettingsAction(forInput: .QUICK_PLAYER_NEXT_BUTTON))
    }
    
    func goBack() {
        
    }
    
    func openPlaylistScreen(audioInfo: AudioInfo, playlist: AudioPlaylist) {
        
    }
    
    func onMediaAlbumsLoad(dataSource: AlbumsViewDataSource?, albumTitles: [String]) {
        
    }
    
    func onPlaylistSongsLoad(name: String, dataSource: PlaylistViewDataSource?, playingTrackIndex: UInt?) {
        
    }
    
    func onUserPlaylistsLoad(audioInfo: AudioInfo, dataSource: ListsViewDataSource?) {
        
    }
    
    func openPlayerScreen(playlist: AudioPlaylist) {
        
    }
    
    func updatePlayerScreen(playlist: AudioPlaylist) {
        
    }
    
    func searchQueryResults(query: String, dataSource: SearchViewDataSource?, resultsCount: UInt, searchTip: String?) {
        
    }
    
    func onResetSettingsDefaults() {
        
    }
    
    func onThemeSelect(_ value: AppTheme) {
        
    }
    
    func onTrackSortingSelect(_ value: TrackSorting) {
        
    }
    
    func onShowVolumeBarSelect(_ value: ShowVolumeBar) {
        
    }
    
    func onPlayerErrorEncountered(_ error: Error) {
        
    }
}
