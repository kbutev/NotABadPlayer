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
    case Theme; case TrackSorting; case ShowVolumeBar; case OpenPlayerOnPlay;
    case PlayerVolumeUp; case PlayerVolumeDown; case PlayerRecall; case PlayerPrevious; case PlayerNext; case PlayerSwipeL; case PlayerSwipeR;
    case QPlayerVolumeUp; case QPlayerVolumeDown; case QPlayerPrevious; case QPlayerNext;
}

protocol SettingsActionDelegate: class {
    func onThemeSelect(_ value: AppTheme)
    func onTrackSortingSelect(_ value: TrackSorting)
    func onShowVolumeBarSelect(_ value: ShowVolumeBar)
    func onOpenPlayerOnPlaySelect(_ value: OpenPlayerOnPlay)
    func onKeybindSelect(input: ApplicationInput, action: ApplicationAction)
    
    func onResetSettingsDefaults()
}

class SettingsView : UIView
{
    public static let HORIZONTAL_MARGIN: CGFloat = 10
    
    public weak var delegate: SettingsActionDelegate?
    
    private var initialized: Bool = false
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var pickAppTheme: SettingsPickView!
    @IBOutlet weak var pickTrackSorting: SettingsPickView!
    @IBOutlet weak var pickShowVolumeBar: SettingsPickView!
    @IBOutlet weak var pickOpenPlayerOnPlay: SettingsPickView!
    
    @IBOutlet weak var pickKeybindPlayerVolumeUp: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerVolumeDown: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerRecall: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerPrevious: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerNext: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerSwipeL: SettingsPickView!
    @IBOutlet weak var pickKeybindPlayerSwipeR: SettingsPickView!
    @IBOutlet weak var pickKeybindQPlayerVolumeUp: SettingsPickView!
    @IBOutlet weak var pickKeybindQPlayerVolumeDown: SettingsPickView!
    @IBOutlet weak var pickKeybindQPlayerPrevious: SettingsPickView!
    @IBOutlet weak var pickKeybindQPlayerNext: SettingsPickView!
    
    @IBOutlet weak var resetDefaultsButton: UIButton!
    
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
        setupPickerValues(.ShowVolumeBar)
        setupPickerValues(.OpenPlayerOnPlay)
        setupPickerValues(.PlayerVolumeUp)
        setupPickerValues(.PlayerVolumeDown)
        setupPickerValues(.PlayerRecall)
        setupPickerValues(.PlayerPrevious)
        setupPickerValues(.PlayerNext)
        setupPickerValues(.PlayerSwipeL)
        setupPickerValues(.PlayerSwipeR)
        setupPickerValues(.QPlayerVolumeUp)
        setupPickerValues(.QPlayerVolumeDown)
        setupPickerValues(.QPlayerPrevious)
        setupPickerValues(.QPlayerNext)
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
        
        // Base
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: SettingsView.HORIZONTAL_MARGIN).isActive = true
        scrollView.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -SettingsView.HORIZONTAL_MARGIN).isActive = true
        scrollView.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
        
        // Set scroll content size of the scroll view
        resizeScrollViewContentSize()
        
        // User interaction
        resetDefaultsButton.addTarget(self, action: #selector(actionResetDefaultsButton), for: .touchUpInside)
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
    
    public func selectTheme(_ value: AppTheme) {
        if let index = AppTheme.allCases.firstIndex(of: value)
        {
            pickAppTheme.selectOption(index: UInt(index))
        }
    }
    
    public func selectTrackSorting(_ value: TrackSorting) {
        if let index = TrackSorting.allCases.firstIndex(of: value)
        {
            pickTrackSorting.selectOption(index: UInt(index))
        }
    }
    
    public func selectShowVolumeBar(_ value: ShowVolumeBar) {
        if let index = ShowVolumeBar.allCases.firstIndex(of: value)
        {
            pickAppTheme.selectOption(index: UInt(index))
        }
    }
    
    public func selectOpenPlayerOnPlay(_ value: OpenPlayerOnPlay) {
        if let index = OpenPlayerOnPlay.allCases.firstIndex(of: value)
        {
            pickOpenPlayerOnPlay.selectOption(index: UInt(index))
        }
    }
    
    public func selectKeybind(keybind: ApplicationInput, action: ApplicationAction) {
        guard let index = ApplicationAction.allCases.index(of: action) else {
            return
        }
        
        switch keybind {
        case .PLAYER_VOLUME_UP_BUTTON:
            pickKeybindPlayerVolumeUp.selectOption(index: UInt(index))
            break
        case .PLAYER_VOLUME_DOWN_BUTTON:
            pickKeybindPlayerVolumeDown.selectOption(index: UInt(index))
            break
        case .PLAYER_RECALL:
            pickKeybindPlayerRecall.selectOption(index: UInt(index))
            break
        case .PLAYER_PREVIOUS_BUTTON:
            pickKeybindPlayerPrevious.selectOption(index: UInt(index))
            break
        case .PLAYER_NEXT_BUTTON:
            pickKeybindPlayerNext.selectOption(index: UInt(index))
            break
        case .PLAYER_SWIPE_LEFT:
            pickKeybindPlayerSwipeL.selectOption(index: UInt(index))
            break
        case .PLAYER_SWIPE_RIGHT:
            pickKeybindPlayerSwipeR.selectOption(index: UInt(index))
            break
        case .QUICK_PLAYER_VOLUME_UP_BUTTON:
            pickKeybindQPlayerVolumeUp.selectOption(index: UInt(index))
            break
        case .QUICK_PLAYER_VOLUME_DOWN_BUTTON:
            pickKeybindQPlayerVolumeDown.selectOption(index: UInt(index))
            break
        case .QUICK_PLAYER_PREVIOUS_BUTTON:
            pickKeybindQPlayerPrevious.selectOption(index: UInt(index))
            break
        case .QUICK_PLAYER_NEXT_BUTTON:
            pickKeybindQPlayerNext.selectOption(index: UInt(index))
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
        case .ShowVolumeBar:
            return pickShowVolumeBar
        case .OpenPlayerOnPlay:
            return pickOpenPlayerOnPlay
        case .PlayerVolumeUp:
            return pickKeybindPlayerVolumeUp
        case .PlayerVolumeDown:
            return pickKeybindPlayerVolumeDown
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
        }
    }
    
    private func setupPickerValues(_ type: SettingsPickerValue) {
        let pickerView: SettingsPickView = getPickerView(for: type)
        
        var options: [String] = []
        
        var title = ""
        
        switch type {
        case .Theme:
            title = "Theme"
            for option in AppTheme.stringValues()
            {
                options.append(option.replacingOccurrences(of: "_", with: " "))
            }
            break
        case .TrackSorting:
            title = "Track Sorting"
            for option in TrackSorting.stringValues()
            {
                options.append(option.replacingOccurrences(of: "_", with: " "))
            }
            break
        case .ShowVolumeBar:
            title = "Show Volume Bar"
            for option in ShowVolumeBar.stringValues()
            {
                options.append(option.replacingOccurrences(of: "_", with: " "))
            }
            break
        case .OpenPlayerOnPlay:
            title = "Play opens player"
            for option in OpenPlayerOnPlay.stringValues()
            {
                options.append(option.replacingOccurrences(of: "_", with: " "))
            }
            break
        case .PlayerVolumeUp:
            title = "Player Volume U"
            options = applicationActionsAsStrings()
            break
        case .PlayerVolumeDown:
            title = "Player Volume D"
            options = applicationActionsAsStrings()
            break
        case .PlayerRecall:
            title = "Player Recall"
            options = applicationActionsAsStrings()
            break
        case .PlayerPrevious:
            title = "Player Previous"
            options = applicationActionsAsStrings()
            break
        case .PlayerNext:
            title = "Player Next"
            options = applicationActionsAsStrings()
            break
        case .PlayerSwipeL:
            title = "Player Swipe L"
            options = applicationActionsAsStrings()
            break
        case .PlayerSwipeR:
            title = "Player Swipe R"
            options = applicationActionsAsStrings()
            break
        case .QPlayerVolumeUp:
            title = "QPlayer Volume U"
            options = applicationActionsAsStrings()
            break
        case .QPlayerVolumeDown:
            title = "QPlayer Volume D"
            options = applicationActionsAsStrings()
            break
        case .QPlayerPrevious:
            title = "QPlayer Previous"
            options = applicationActionsAsStrings()
            break
        case .QPlayerNext:
            title = "QPlayer Next"
            options = applicationActionsAsStrings()
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
        getPickerView(for: .ShowVolumeBar).isUserInteractionEnabled = value
        getPickerView(for: .PlayerVolumeUp).isUserInteractionEnabled = value
        getPickerView(for: .PlayerVolumeDown).isUserInteractionEnabled = value
        getPickerView(for: .PlayerRecall).isUserInteractionEnabled = value
        getPickerView(for: .PlayerPrevious).isUserInteractionEnabled = value
        getPickerView(for: .PlayerNext).isUserInteractionEnabled = value
        getPickerView(for: .PlayerSwipeL).isUserInteractionEnabled = value
        getPickerView(for: .PlayerSwipeR).isUserInteractionEnabled = value
        getPickerView(for: .QPlayerVolumeUp).isUserInteractionEnabled = value
        getPickerView(for: .QPlayerVolumeDown).isUserInteractionEnabled = value
        getPickerView(for: .QPlayerPrevious).isUserInteractionEnabled = value
        getPickerView(for: .QPlayerNext).isUserInteractionEnabled = value
    }
    
    private func applicationActionsAsStrings() -> [String] {
        var options: [String] = []
        
        for option in ApplicationAction.stringValues()
        {
            options.append(option.replacingOccurrences(of: "_", with: " "))
        }
        
        return options
    }
}

// Actions
extension SettingsView {
    @objc func actionResetDefaultsButton() {
        delegate?.onResetSettingsDefaults()
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
    
    func onSelect(source: SettingsPickerValue, index: UInt) {
        // Forward to delegate
        switch source {
        case .Theme:
            if index < AppTheme.allCases.count
            {
                delegate?.onThemeSelect(AppTheme.allCases[Int(index)])
            }
            break
        case .TrackSorting:
            if index < TrackSorting.allCases.count
            {
                delegate?.onTrackSortingSelect(TrackSorting.allCases[Int(index)])
            }
            break
        case .ShowVolumeBar:
            if index < ShowVolumeBar.allCases.count
            {
                delegate?.onShowVolumeBarSelect(ShowVolumeBar.allCases[Int(index)])
            }
            break
        case .OpenPlayerOnPlay:
            if index < OpenPlayerOnPlay.allCases.count
            {
                delegate?.onOpenPlayerOnPlaySelect(OpenPlayerOnPlay.allCases[Int(index)])
            }
            break
        case .PlayerVolumeUp:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .PLAYER_VOLUME_UP_BUTTON, action: ApplicationAction.allCases[Int(index)])
            }
            break
        case .PlayerVolumeDown:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .PLAYER_VOLUME_DOWN_BUTTON, action: ApplicationAction.allCases[Int(index)])
            }
            break
        case .PlayerRecall:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .PLAYER_RECALL, action: ApplicationAction.allCases[Int(index)])
            }
            break
        case .PlayerPrevious:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .PLAYER_PREVIOUS_BUTTON, action: ApplicationAction.allCases[Int(index)])
            }
            break
        case .PlayerNext:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .PLAYER_NEXT_BUTTON, action: ApplicationAction.allCases[Int(index)])
            }
            break
        case .PlayerSwipeL:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .PLAYER_SWIPE_LEFT, action: ApplicationAction.allCases[Int(index)])
            }
            break
        case .PlayerSwipeR:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .PLAYER_SWIPE_RIGHT, action: ApplicationAction.allCases[Int(index)])
            }
            break
        case .QPlayerVolumeUp:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .QUICK_PLAYER_VOLUME_UP_BUTTON, action: ApplicationAction.allCases[Int(index)])
            }
            break
        case .QPlayerVolumeDown:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .QUICK_PLAYER_VOLUME_DOWN_BUTTON, action: ApplicationAction.allCases[Int(index)])
            }
            break
        case .QPlayerPrevious:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .QUICK_PLAYER_PREVIOUS_BUTTON, action: ApplicationAction.allCases[Int(index)])
            }
            break
        case .QPlayerNext:
            if index < ApplicationAction.allCases.count
            {
                delegate?.onKeybindSelect(input: .QUICK_PLAYER_NEXT_BUTTON, action: ApplicationAction.allCases[Int(index)])
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
