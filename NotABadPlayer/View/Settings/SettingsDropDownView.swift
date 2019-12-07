//
//  SettingsDropDownView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 26.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import iOSDropDown

class SettingsDropDownView: DropDown {
    // Because @table is almost impossible to access,
    // we will scroll to the selected item inside the setter of @isSelected
    override var isSelected: Bool {
        get {
            return super.isSelected
        }
        
        set {
            super.isSelected = newValue
            
            if newValue
            {
                scrollToSelectedItem()
            }
        }
    }
    
    private var _optionsUnformatted: [String] = []
    
    // Options string values always remove their "_" occurances with space
    // Use @optionsUnformatted to retrieve the original values back
    public var options: [String] {
        get {
            return self.optionArray
        }
    }
    
    // Options with their original values, no formatting
    public var optionsUnformatted: [String] {
        get {
            return self._optionsUnformatted
        }
        
        set {
            self._optionsUnformatted = newValue
            
            var values: [String] = []
            
            for string in newValue
            {
                values.append(string.replacingOccurrences(of: "_", with: optionsUnderscoreReplacement))
            }
            
            self.optionArray = values
        }
    }
    
    public var optionsUnderscoreReplacement = " "
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public func scrollToSelectedItem() {
        guard let parent = self.superview else {
            return
        }
        
        guard let selectedTableIndex = self.selectedIndex else {
            return
        }
        
        // We cant access directly the table, so lets find it trough @subviews
        for subview in parent.subviews
        {
            if let table = subview as? UITableView
            {
                table.scrollToRow(at: IndexPath(row: selectedTableIndex, section: 0), at: .middle, animated: false)
                
                return
            }
        }
    }
    
    public func selectOption(at index: UInt) {
        self.text = options[Int(index)]
        self.selectedIndex = Int(index)
    }
    
    public func selectOption(action: ApplicationAction) {
        for e in 0..<optionsUnformatted.count
        {
            if optionsUnformatted[e] == action.rawValue
            {
                self.text = options[e]
                self.selectedIndex = e
                break
            }
        }
    }
}
