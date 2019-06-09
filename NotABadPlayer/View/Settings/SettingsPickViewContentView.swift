//
//  SettingsPickContentView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 26.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class SettingsPickContentView : UIView {
    public static let TITLE_WIDTH: CGFloat = 140
    public static let DROP_DOWN_WIDTH: CGFloat = 140
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dropDownView: SettingsDropDownView!
    
    private var initialized: Bool = false
    
    class func create(owner: Any) -> SettingsPickContentView? {
        let bundle = Bundle.main
        let nibName = String(describing: SettingsPickContentView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? SettingsPickContentView
    }
    
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
    
    func setup() {
        let parent = superview!
        
        // App theme setup
        setupAppTheme()
        
        // Title setup
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: SettingsPickContentView.TITLE_WIDTH).isActive = true
        
        // Drop down setup
        dropDownView.translatesAutoresizingMaskIntoConstraints = false
        dropDownView.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        dropDownView.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        dropDownView.widthAnchor.constraint(equalToConstant: SettingsPickContentView.DROP_DOWN_WIDTH).isActive = true
    }
    
    public func setupAppTheme() {
        self.backgroundColor = .clear
        dropDownView.selectedRowColor = AppTheme.shared.colorFor(.SETTINGS_DROP_DOWN_SELECTION)
        titleLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
    }
}
