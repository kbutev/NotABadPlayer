//
//  SettingsPickView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 25.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import iOSDropDown

protocol SettingsPickActionDelegate: class {
    func onOpen(source: SettingsPickerValue)
    func onSelect(source: SettingsPickerValue, index: UInt)
    func onClose(source: SettingsPickerValue)
}

class SettingsPickView : UIView {
    public static let HEIGHT: CGFloat = 48
    
    private weak var _delegate: SettingsPickActionDelegate?
    
    public var delegate: SettingsPickActionDelegate? {
        get {
            return self._delegate
        }
        
        set {
            self._delegate = newValue
            
            setupInteraction()
        }
    }
    
    public var type: SettingsPickerValue = .PlayerPrevious
    
    private weak var content: SettingsPickContentView!
    
    var titleLabel: UILabel! {
        get {
            return content.titleLabel
        }
    }
    
    var dropDownView: SettingsDropDownView! {
        get {
            return content.dropDownView
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        content = SettingsPickContentView.create(owner: self)
        addSubview(content)
        backgroundColor = .clear
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        let parent = superview!
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalTo: parent.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: SettingsPickView.HEIGHT).isActive = true
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // When the drop down is dropped down, bypass the frame of this view
        // and go straight to the subviews testing
        if dropDownView.isSelected
        {
            for subview in subviews
            {
                if let result = subview.hitTest(point, with: event)
                {
                    return result
                }
            }
        }
        
        // Otherwise, normal testing
        return super.hitTest(point, with: event)
    }
    
    public func setTitle(title: String) {
        titleLabel.text = title
    }
    
    public func setPickOptions(options: [String]) {
        let wasEmpty = dropDownView.optionArray.count == 0
        
        dropDownView.optionArray = options
        dropDownView.text = dropDownView.optionArray.first
        
        if wasEmpty
        {
            dropDownView.selectedIndex = 0
        }
    }
    
    public func selectOption(index: UInt) {
        dropDownView.text = dropDownView.optionArray[Int(index)]
        dropDownView.selectedIndex = Int(index)
    }
    
    public func showPickerView() {
        dropDownView.isHidden = false
    }
    
    public func hidePickerView() {
        dropDownView.isHidden = true
    }
    
    private func setupInteraction() {
        dropDownView.listWillAppear(completion: {[weak self] () -> () in
            if let view = self
            {
                view.bringToFront()
                view.delegate?.onOpen(source: view.type)
            }
        })
        
        dropDownView.didSelect(completion: {[weak self] (_ selectedText: String, _ index: Int , _ id:Int ) -> () in
            if let view = self
            {
                view.selectOption(index: UInt(index))
                view.delegate?.onSelect(source: view.type, index: UInt(index))
            }
        })
        
        dropDownView.listWillDisappear(completion: {[weak self] () -> () in
            if let view = self
            {
                view.delegate?.onClose(source: view.type)
            }
        })
    }
    
    private func bringToFront() {
        self.superview!.bringSubviewToFront(self)
    }
}

