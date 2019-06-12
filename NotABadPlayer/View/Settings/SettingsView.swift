//
//  SettingsView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 25.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import iOSDropDown

enum SettingsPickerValue {
    case Theme; case TrackSorting; case OpenPlayerOnPlay;
    case PlayerVolumeUp; case PlayerVolumeDown; case PlayerVolume; case PlayerRecall; case PlayerPrevious; case PlayerNext; case PlayerSwipeL; case PlayerSwipeR;
    case QPlayerVolumeUp; case QPlayerVolumeDown; case QPlayerPrevious; case QPlayerNext;
    case LockPlayerPrevious; case LockPlayerNext;
}

protocol SettingsActionDelegate: class {
    func onThemeSelect(_ value: AppThemeValue)
    func onTrackSortingSelect(_ value: TrackSorting)
    func onShowVolumeBarSelect(_ value: ShowVolumeBar)
    func onOpenPlayerOnPlaySelect(_ value: OpenPlayerOnPlay)
    func onKeybindSelect(input: ApplicationInput, action: ApplicationAction)
    
    func onResetSettingsDefaults()
}

class SettingsView : UIView
{
    public static let HORIZONTAL_MARGIN: CGFloat = 10
    
    public weak var delegate: BaseViewDelegate?
    
    private var initialized: Bool = false
    
    public var onAppThemeSelectCallback: (AppThemeValue)->Void = {(value) in }
    public var onTrackSortingSelectCallback: (TrackSorting)->Void = {(value) in }
    public var onShowVolumeBarSelectCallback: (ShowVolumeBar)->Void = {(value) in }
    public var onOpenPlayerOnPlaySelectCallback: (OpenPlayerOnPlay)->Void = {(value) in }
    public var onKeybindSelectCallback: (ApplicationInput, ApplicationAction)->Void = {(input, action) in }
    public var onResetSettingsDefaults: ()->Void = {() in }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var appearanceLabel: UILabel!
    @IBOutlet weak var pickAppTheme: SettingsPickView!
    @IBOutlet weak var pickTrackSorting: SettingsPickView!
    @IBOutlet weak var pickOpenPlayerOnPlay: SettingsPickView!
    
    @IBOutlet weak var keyBindsLabel: UILabel!
    @IBOutlet weak var pickKeybindPlayerVolumeUp: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerVolumeDown: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerVolume: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerRecall: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerPrevious: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerNext: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerSwipeL: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerSwipeR: SettingsPickView!
    @IBOutlet weak var pickKeybindQPlayerVolumeUp: SettingsPickView!
    @IBOutlet weak var pickKeybindQPlayerVolumeDown: SettingsPickView!
    @IBOutlet weak var pickKeybindQPlayerPrevious: SettingsPickView!
    @IBOutlet weak var pickKeybindQPlayerNext: SettingsPickView!
    @IBOutlet weak var pickKeybindLockPlayerPrevious: SettingsPickView!
    @IBOutlet weak var pickKeybindLockPlayerNext: SettingsPickView!
    
    @IBOutlet weak var resetLabel: UILabel!
    @IBOutlet weak var resetDefaultsButton: UIButton!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var aboutInfoView: UITextView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        // Picker views setup
        setupPickerValues(.Theme)
        setupPickerValues(.TrackSorting)
        setupPickerValues(.OpenPlayerOnPlay)
        setupPickerValues(.PlayerVolumeUp)
        setupPickerValues(.PlayerVolumeDown)
        setupPickerValues(.PlayerVolume)
        setupPickerValues(.PlayerRecall)
        setupPickerValues(.PlayerPrevious)
        setupPickerValues(.PlayerNext)
        setupPickerValues(.PlayerSwipeL)
        setupPickerValues(.PlayerSwipeR)
        setupPickerValues(.QPlayerVolumeUp)
        setupPickerValues(.QPlayerVolumeDown)
        setupPickerValues(.QPlayerPrevious)
        setupPickerValues(.QPlayerNext)
        setupPickerValues(.LockPlayerPrevious)
        setupPickerValues(.LockPlayerNext)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if !initialized
        {
            initialized = true
            setup()
        }
    }
    
    private func setup() {
        let guide = self
        
        // App theme setup
        setupAppTheme()
        
        // Scroll setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: SettingsView.HORIZONTAL_MARGIN).isActive = true
        scrollView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -SettingsView.HORIZONTAL_MARGIN).isActive = true
        scrollView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
        
        resizeScrollViewContentSize()
        
        // About info setup
        aboutInfoView.text = Text.value(.SettingsAbout)
        
        // User interaction setup
        resetDefaultsButton.addTarget(self, action: #selector(actionResetDefaultsButton), for: .touchUpInside)
    }
    
    public func setupAppTheme() {
        self.backgroundColor = AppTheme.shared.colorFor(.STANDART_BACKGROUND)
        
        appearanceLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        
        keyBindsLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        
        resetLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        
        aboutLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        aboutInfoView.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        aboutInfoView.backgroundColor = .clear
        
        resetDefaultsButton.tintColor = AppTheme.shared.colorFor(.STANDART_BUTTON)
    }
    
    private func resizeScrollViewContentSize() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {[weak self] () in
            if let settingsView = self
            {
                var contentRect = CGRect.zero
                
                for view in settingsView.scrollView.subviews {
                    contentRect = contentRect.union(view.frame)
                }
                
                settingsView.scrollView.contentSize = contentRect.size
            }
        })
    }
    
    public func selectTheme(_ value: AppThemeValue) {
        if let index = AppThemeValue.allCases.firstIndex(of: value)
        {
            pickAppTheme.selectOption(at: UInt(index))
        }
    }
    
    public func selectTrackSorting(_ value: TrackSorting) {
        if let index = TrackSorting.allCases.firstIndex(of: value)
        {
            pickTrackSorting.selectOption(at: UInt(index))
        }
    }
    
    public func selectOpenPlayerOnPlay(_ value: OpenPlayerOnPlay) {
        if let index = OpenPlayerOnPlay.allCases.firstIndex(of: value)
        {
            pickOpenPlayerOnPlay.selectOption(at: UInt(index))
        }
    }
    
    public func selectKeybind(keybind: ApplicationInput, action: ApplicationAction) {
        switch keybind {
        case .PLAYER_VOLUME_UP_BUTTON:
            pickKeybindPlayerVolumeUp.selectOption(action: action)
            break
        case .PLAYER_VOLUME_DOWN_BUTTON:
            pickKeybindPlayerVolumeDown.selectOption(action: action)
            break
        case .PLAYER_VOLUME:
            pickKeybindPlayerVolume.selectOption(action: action)
            break
        case .PLAYER_RECALL:
            pickKeybindPlayerRecall.selectOption(action: action)
            break
        case .PLAYER_PREVIOUS_BUTTON:
            pickKeybindPlayerPrevious.selectOption(action: action)
            break
        case .PLAYER_NEXT_BUTTON:
            pickKeybindPlayerNext.selectOption(action: action)
            break
        case .PLAYER_SWIPE_LEFT:
            pickKeybindPlayerSwipeL.selectOption(action: action)
            break
        case .PLAYER_SWIPE_RIGHT:
            pickKeybindPlayerSwipeR.selectOption(action: action)
            break
        case .QUICK_PLAYER_VOLUME_UP_BUTTON:
            pickKeybindQPlayerVolumeUp.selectOption(action: action)
            break
        case .QUICK_PLAYER_VOLUME_DOWN_BUTTON:
            pickKeybindQPlayerVolumeDown.selectOption(action: action)
            break
        case .QUICK_PLAYER_PREVIOUS_BUTTON:
            pickKeybindQPlayerPrevious.selectOption(action: action)
            break
        case .QUICK_PLAYER_NEXT_BUTTON:
            pickKeybindQPlayerNext.selectOption(action: action)
            break
        case .LOCK_PLAYER_PREVIOUS_BUTTON:
            pickKeybindLockPlayerPrevious.selectOption(action: action)
            break
        case .LOCK_PLAYER_NEXT_BUTTON:
            pickKeybindLockPlayerNext.selectOption(action: action)
            break
        default:
            break
        }
    }
}

// Picker views
extension SettingsView {
    private func getPickerView(for type: SettingsPickerValue) -> SettingsPickView {
        switch type {
        case .Theme:
            return pickAppTheme
        case .TrackSorting:
            return pickTrackSorting
        case .OpenPlayerOnPlay:
            return pickOpenPlayerOnPlay
        case .PlayerVolumeUp:
            return pickKeybindPlayerVolumeUp
        case .PlayerVolumeDown:
            return pickKeybindPlayerVolumeDown
        case .PlayerVolume:
            return pickKeybindPlayerVolume
        case .PlayerRecall:
            return pickKeybindPlayerRecall
        case .PlayerPrevious:
            return pickKeybindPlayerPrevious
        case .PlayerNext:
            return pickKeybindPlayerNext
        case .PlayerSwipeL:
            return pickKeybindPlayerSwipeL
        case .PlayerSwipeR:
            return pickKeybindPlayerSwipeR
        case .QPlayerVolumeUp:
            return pickKeybindQPlayerVolumeUp
        case .QPlayerVolumeDown:
            return pickKeybindQPlayerVolumeDown
        case .QPlayerPrevious:
            return pickKeybindQPlayerPrevious
        case .QPlayerNext:
            return pickKeybindQPlayerNext
        case .LockPlayerPrevious:
            return pickKeybindLockPlayerPrevious
        case .LockPlayerNext:
            return pickKeybindLockPlayerNext
        }
    }
    
    private func setupPickerValues(_ type: SettingsPickerValue) {
        let pickerView: SettingsPickView = getPickerView(for: type)
        
        var options: [String] = []
        
        var title = ""
        
        switch type {
        case .Theme:
            title = Text.value(.SettingsTheme)
            options = AppThemeValue.stringValues()
            break
        case .TrackSorting:
            title = Text.value(.SettingsTrackSorting)
            options = TrackSorting.stringValues()
            break
        case .OpenPlayerOnPlay:
            title = Text.value(.SettingsPlayOpensPlayer)
            options = OpenPlayerOnPlay.stringValues()
            break
        case .PlayerVolumeUp:
            title = Text.value(.SettingsPlayerVolumeUp)
            options = applicationActionsAsStrings()
            break
        case .PlayerVolumeDown:
            title = Text.value(.SettingsPlayerVolumeDown)
            options = applicationActionsAsStrings()
            break
        case .PlayerVolume:
            title = Text.value(.SettingsPlayerVolume)
            options = applicationActionsAsStrings()
            break
        case .PlayerRecall:
            title = Text.value(.SettingsPlayerRecall)
            options = applicationActionsAsStrings()
            break
        case .PlayerPrevious:
            title = Text.value(.SettingsPlayerPrevious)
            options = applicationActionsAsStrings()
            break
        case .PlayerNext:
            title = Text.value(.SettingsPlayerNext)
            options = applicationActionsAsStrings()
            break
        case .PlayerSwipeL:
            title = Text.value(.SettingsPlayerSwipeL)
            options = applicationActionsAsStrings()
            break
        case .PlayerSwipeR:
            title = Text.value(.SettingsPlayerSwipeR)
            options = applicationActionsAsStrings()
            break
        case .QPlayerVolumeUp:
            title = Text.value(.SettingsQPlayerVolumeU)
            options = applicationActionsAsStrings()
            break
        case .QPlayerVolumeDown:
            title = Text.value(.SettingsQPlayerVolumeD)
            options = applicationActionsAsStrings()
            break
        case .QPlayerPrevious:
            title = Text.value(.SettingsQPlayerPrevious)
            options = applicationActionsAsStrings()
            break
        case .QPlayerNext:
            title = Text.value(.SettingsQPlayerNext)
            options = applicationActionsAsStrings()
            break
        case .LockPlayerPrevious:
            title = Text.value(.SettingsLockPlayerPrevious)
            options = applicationLPlayerPreviousActionsAsStrings()
            break
        case .LockPlayerNext:
            title = Text.value(.SettingsLockPlayerNext)
            options = applicationLPlayerNextActionsAsStrings()
            break
        }
        
        pickerView.type = type
        pickerView.delegate = self
        pickerView.setTitle(title: title)
        pickerView.setPickOptions(options: options)
    }
    
    private func enableAllPickerViews() {
        setUserInteractionStateForAllPickerViews(true)
    }
    
    private func disableAllPickerViews() {
        setUserInteractionStateForAllPickerViews(false)
    }
    
    private func setUserInteractionStateForAllPickerViews(_ value: Bool) {
        getPickerView(for: .Theme).isUserInteractionEnabled = value
        getPickerView(for: .TrackSorting).isUserInteractionEnabled = value
        getPickerView(for: .PlayerVolumeUp).isUserInteractionEnabled = value
        getPickerView(for: .PlayerVolumeDown).isUserInteractionEnabled = value
        getPickerView(for: .PlayerVolume).isUserInteractionEnabled = value
        getPickerView(for: .PlayerRecall).isUserInteractionEnabled = value
        getPickerView(for: .PlayerPrevious).isUserInteractionEnabled = value
        getPickerView(for: .PlayerNext).isUserInteractionEnabled = value
        getPickerView(for: .PlayerSwipeL).isUserInteractionEnabled = value
        getPickerView(for: .PlayerSwipeR).isUserInteractionEnabled = value
        getPickerView(for: .QPlayerVolumeUp).isUserInteractionEnabled = value
        getPickerView(for: .QPlayerVolumeDown).isUserInteractionEnabled = value
        getPickerView(for: .QPlayerPrevious).isUserInteractionEnabled = value
        getPickerView(for: .QPlayerNext).isUserInteractionEnabled = value
        getPickerView(for: .LockPlayerPrevious).isUserInteractionEnabled = value
        getPickerView(for: .LockPlayerNext).isUserInteractionEnabled = value
    }
    
    private func applicationActionsAsStrings() -> [String] {
        return ApplicationAction.stringValues()
    }
    
    private func applicationLPlayerPreviousActionsAsStrings() -> [String] {
        return [ApplicationAction.PREVIOUS.rawValue,
                ApplicationAction.BACKWARDS_8.rawValue,
                ApplicationAction.BACKWARDS_15.rawValue,
                ApplicationAction.BACKWARDS_30.rawValue,
                ApplicationAction.BACKWARDS_60.rawValue]
    }
    
    private func applicationLPlayerNextActionsAsStrings() -> [String] {
        return [ApplicationAction.NEXT.rawValue,
                ApplicationAction.FORWARDS_8.rawValue,
                ApplicationAction.FORWARDS_15.rawValue,
                ApplicationAction.FORWARDS_30.rawValue,
                ApplicationAction.FORWARDS_60.rawValue]
    }
}

// Actions
extension SettingsView {
    @objc func actionResetDefaultsButton() {
        self.onResetSettingsDefaults()
    }
}

// View action delegate
extension SettingsView: SettingsPickActionDelegate {
    func onOpen(source: SettingsPickerValue) {
        // Interface update
        scrollView.isScrollEnabled = false
        
        let pview = getPickerView(for: source)
        
        disableAllPickerViews()
        pview.isUserInteractionEnabled = true
    }
    
    private func getKeybindOptionAction(options: [String], at index: UInt) -> ApplicationAction? {
        guard index < options.count else {
            return nil
        }
        
        return ApplicationAction(rawValue: options[Int(index)])
    }
    
    func onSelect(source: SettingsPickerValue, index: UInt) {
        // Forward to delegate
        switch source {
        case .Theme:
            if index < AppThemeValue.allCases.count
            {
                self.onAppThemeSelectCallback(AppThemeValue.allCases[Int(index)])
            }
            break
        case .TrackSorting:
            if index < TrackSorting.allCases.count
            {
                self.onTrackSortingSelectCallback(TrackSorting.allCases[Int(index)])
            }
            break
        case .OpenPlayerOnPlay:
            if index < OpenPlayerOnPlay.allCases.count
            {
                self.onOpenPlayerOnPlaySelectCallback(OpenPlayerOnPlay.allCases[Int(index)])
            }
            break
        case .PlayerVolumeUp:
            if let option = getKeybindOptionAction(options: pickKeybindPlayerVolumeUp.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.PLAYER_VOLUME_UP_BUTTON, option)
            }
            break
        case .PlayerVolumeDown:
            if let option = getKeybindOptionAction(options: pickKeybindPlayerVolumeDown.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.PLAYER_VOLUME_DOWN_BUTTON, option)
            }
            break
        case .PlayerVolume:
            if let option = getKeybindOptionAction(options: pickKeybindPlayerVolume.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.PLAYER_VOLUME, option)
            }
            break
        case .PlayerRecall:
            if let option = getKeybindOptionAction(options: pickKeybindPlayerRecall.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.PLAYER_RECALL, option)
            }
            break
        case .PlayerPrevious:
            if let option = getKeybindOptionAction(options: pickKeybindPlayerPrevious.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.PLAYER_PREVIOUS_BUTTON, option)
            }
            break
        case .PlayerNext:
            if let option = getKeybindOptionAction(options: pickKeybindPlayerNext.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.PLAYER_NEXT_BUTTON, option)
            }
            break
        case .PlayerSwipeL:
            if let option = getKeybindOptionAction(options: pickKeybindPlayerSwipeL.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.PLAYER_SWIPE_LEFT, option)
            }
            break
        case .PlayerSwipeR:
            if let option = getKeybindOptionAction(options: pickKeybindPlayerSwipeR.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.PLAYER_SWIPE_RIGHT, option)
            }
            break
        case .QPlayerVolumeUp:
            if let option = getKeybindOptionAction(options: pickKeybindQPlayerVolumeUp.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.QUICK_PLAYER_VOLUME_UP_BUTTON, option)
            }
            break
        case .QPlayerVolumeDown:
            if let option = getKeybindOptionAction(options: pickKeybindQPlayerVolumeDown.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.QUICK_PLAYER_VOLUME_DOWN_BUTTON, option)
            }
            break
        case .QPlayerPrevious:
            if let option = getKeybindOptionAction(options: pickKeybindQPlayerPrevious.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.QUICK_PLAYER_PREVIOUS_BUTTON, option)
            }
            break
        case .QPlayerNext:
            if let option = getKeybindOptionAction(options: pickKeybindQPlayerNext.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.QUICK_PLAYER_NEXT_BUTTON, option)
            }
            break
        case .LockPlayerPrevious:
            if let option = getKeybindOptionAction(options: pickKeybindLockPlayerPrevious.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.LOCK_PLAYER_PREVIOUS_BUTTON, option)
            }
            break
        case .LockPlayerNext:
            if let option = getKeybindOptionAction(options: pickKeybindLockPlayerNext.dropDownView.optionArray, at: index)
            {
                self.onKeybindSelectCallback(.LOCK_PLAYER_NEXT_BUTTON, option)
            }
            break
        }
    }
    
    func onClose(source: SettingsPickerValue) {
        // Interface update
        scrollView.isScrollEnabled = true
        
        enableAllPickerViews()
    }
}

// Builder
extension SettingsView {
    class func create(owner: Any) -> SettingsView? {
        let bundle = Bundle.main
        let nibName = String(describing: SettingsView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? SettingsView
    }
}
