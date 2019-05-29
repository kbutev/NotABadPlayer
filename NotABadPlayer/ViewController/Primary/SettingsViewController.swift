//
//  SettingsViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol SettingsViewDelegate : class {
    
}

class SettingsViewController: UIViewController, BaseViewController {
    private var baseView: SettingsView?
    
    public var presenter: BasePresenter?
    
    override func loadView() {
        self.baseView = SettingsView.create(owner: self)
        self.view = self.baseView!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.start()
        
        baseView?.delegate = self
        
        selectDefaultPickerValues()
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
    
    func onSwipeUp() {
        
    }
    
    func onSwipeDown() {
        
    }
    
    func onPlayerSeekChanged(positionInPercentage: Double) {
        
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        
    }
    
    func onPlayOrderButtonClick() {
        
    }
    
    func onPlaylistButtonClick() {
        
    }
}

extension SettingsViewController: SettingsActionDelegate {
    func onThemeSelect(_ value: AppTheme) {
        presenter?.onAppThemeChange(themeValue: value)
    }
    
    func onTrackSortingSelect(_ value: TrackSorting) {
        presenter?.onAppSortingChange(albumSorting: .TITLE, trackSorting: value)
    }
    
    func onShowVolumeBarSelect(_ value: ShowVolumeBar) {
        presenter?.onShowVolumeBarSettingChange(value)
    }
    
    func onOpenPlayerOnPlaySelect(_ value: OpenPlayerOnPlay) {
        presenter?.onOpenPlayerOnPlaySettingChange(value)
    }
    
    func onKeybindSelect(input: ApplicationInput, action: ApplicationAction) {
        presenter?.onKeybindChange(action: action, input: input)
    }
    
    func onResetSettingsDefaults() {
        AlertWindows.shared.show(sourceVC: self, withTitle: "", withDescription: "Reset settings to defaults?",
                                 actionLeftText: "NO", actionLeft: nil,
                                 actionRightText: "YES", actionRight: {[weak self] (action) in
                                    self?.presenter?.onAppSettingsReset()
                                    self?.selectDefaultPickerValues()
        })
    }
}

extension SettingsViewController: SettingsViewDelegate {
    
}
