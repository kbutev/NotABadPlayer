//
//  SettingsView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 25.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

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
        
        // Appearance
        updatePickerTitle(title: "Theme", forPicker: .Theme)
        updatePickerOptions(values: ["a", "b"], forPicker: .Theme)
        updatePickerTitle(title: "Track Sorting", forPicker: .TrackSorting)
        updatePickerOptions(values: ["a", "b"], forPicker: .TrackSorting)
        
        // Picker value default values
        
        // Picker value interaction
        pickAppTheme.setPickGesture(forTarget: self, selector: #selector(actionPickerTap(gesture:)))
    }
    
    private func setScrollContentSize() {
        scrollView.contentSize.height = stackView.bounds.size.height // width should be 0, to prevent horizontal scroll
    }
    
    func updatePickerTitle(title: String, forPicker picker: SettingsPickerValue)
    {
        switch picker {
        case .Theme:
            pickAppTheme.setTitle(title: title)
            break
        case .TrackSorting:
            pickTrackSorting.setTitle(title: title)
            break
        default:
            break
        }
    }
    
    func updatePickerOptions(values: [String], forPicker picker: SettingsPickerValue)
    {
        switch picker {
        case .Theme:
            pickAppTheme.setPickOptions(options: values)
            break
        case .TrackSorting:
            pickTrackSorting.setPickOptions(options: values)
            break
        default:
            break
        }
    }
    
    func selectPickerValue(index: UInt, forPicker picker: SettingsPickerValue)
    {
        switch picker {
        case .Theme:
            pickAppTheme.selectOption(index: index)
            break
        case .TrackSorting:
            pickTrackSorting.selectOption(index: index)
            break
        default:
            break
        }
    }
}

extension SettingsView {
    @objc func actionPickerTap(gesture: UIGestureRecognizer) {
        pickTrackSorting.hidePickerView()
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
