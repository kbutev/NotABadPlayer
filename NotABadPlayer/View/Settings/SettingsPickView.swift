//
//  SettingsPickView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 25.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import iOSDropDown

class SettingsPickView : UIView {
    public static let HEIGHT: CGFloat = 32
    
    private weak var content: SettingsPickContentView!
    
    var titleLabel: UILabel! {
        get {
            return content.titleLabel
        }
    }
    
    var dropDownView: DropDown! {
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
    
    func initialize() {
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
    
    func setTitle(title: String) {
        titleLabel.text = title
    }
    
    func setPickOptions(options: [String]) {
        let wasEmpty = dropDownView.optionArray.count == 0
        
        dropDownView.optionArray = options
        dropDownView.text = dropDownView.optionArray.first
        
        if wasEmpty
        {
            dropDownView.selectedIndex = 0
        }
    }
    
    func selectOption(index: UInt) {
        dropDownView.text = dropDownView.optionArray[Int(index)]
        dropDownView.selectedIndex = Int(index)
    }
    
    func showPickerView() {
        dropDownView.isHidden = false
    }
    
    func hidePickerView() {
        dropDownView.isHidden = true
    }
    
    func setPickGesture(forTarget target: UIView, selector: Selector) -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: target, action: selector)
        tap.numberOfTapsRequired = 1
        dropDownView.addGestureRecognizer(tap)
        return tap
    }
}

class SettingsPickContentView : UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dropDownView: DropDown!
    
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
        setup()
    }
    
    func setup() {
        let parent = superview!
        
        backgroundColor = .clear
        
        self.translatesAutoresizingMaskIntoConstraints = false
        self.widthAnchor.constraint(equalTo: parent.widthAnchor).isActive = true
        self.heightAnchor.constraint(equalToConstant: 256).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalToConstant: 128).isActive = true
        
        dropDownView.translatesAutoresizingMaskIntoConstraints = false
        dropDownView.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        dropDownView.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        dropDownView.widthAnchor.constraint(equalToConstant: 128).isActive = true
        dropDownView.selectedRowColor = .orange
    }
}
