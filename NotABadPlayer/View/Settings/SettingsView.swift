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
    case Theme; case TrackSorting; case ShowVolumeBar;
    case PlayerVolumeUp; case PlayerVolumeDown; case PlayerRecall; case PlayerPrevious; case PlayerNext; case PlayerSwipeL; case PlayerSwipeR;
    case QPlayerVolumeUp; case QPlayerVolumeDown; case QPlayerPrevious; case QPlayerNext;
}

class SettingsView : UIView
{
    public static let HORIZONTAL_MARGIN: CGFloat = 10
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var pickAppTheme: SettingsPickView!
    @IBOutlet weak var pickTrackSorting: SettingsPickView!
    
    private var initialized: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
        
        setScrollContentSize()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, multiplier: 1).isActive = true
        
        // Picker setup
        setupPicker(.Theme)
        setupPicker(.TrackSorting)
    }
    
    private func setScrollContentSize() {
        scrollView.contentSize.height = stackView.bounds.size.height // width should be 0, to prevent horizontal scroll
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
        default:
            break
        }
        
        fatalError("SettingsView: picker views are not initialized properly, cannot get picker view for given type")
    }
    
    private func setupPicker(_ type: SettingsPickerValue) {
        let pickerView: SettingsPickView = getPickerView(for: type)
        
        let optionsUgly = ApplicationAction.stringValues()
        var options: [String] = []
        
        for option in optionsUgly
        {
            options.append(option.stringByReplacingFirstOccurrenceOfString(target: "_", replaceString: " "))
        }
        
        var title = ""
        
        switch type {
        case .Theme:
            title = "Theme"
            break
        case .TrackSorting:
            title = "Track Sorting"
            break
        default:
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
    }
}

// View action delegate
extension SettingsView: SettingsPickActionDelegate {
    func onTap(source: SettingsPickerValue) {
        NSLog("onTap")
        
        let pview = getPickerView(for: source)
        
        disableAllPickerViews()
        pview.isUserInteractionEnabled = true
    }
    
    func onSelect(source: SettingsPickerValue, index: UInt) {
        NSLog("onSelect")
    }
    
    func onClose(source: SettingsPickerValue) {
        NSLog("onClose")
        
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
