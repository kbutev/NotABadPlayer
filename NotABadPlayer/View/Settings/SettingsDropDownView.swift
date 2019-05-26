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
}
