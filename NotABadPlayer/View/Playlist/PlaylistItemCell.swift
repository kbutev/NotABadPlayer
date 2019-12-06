//
//  PlaylistItemCell.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class PlaylistItemCell : UICollectionViewCell
{
    public static let CELL_IDENTIFIER = "cell"
    public static let SIZE = CGSize(width: 0, height: 56)
    
    @IBOutlet weak var horizontalStackView: UIStackView!
    @IBOutlet weak var trackNumText: UILabel!
    
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        let guide = self
        
        // App theme setup
        setupAppTheme()
        
        // Track num setup
        trackNumText.translatesAutoresizingMaskIntoConstraints = false
        trackNumText.widthAnchor.constraint(equalToConstant: 32).isActive = true
        trackNumText.heightAnchor.constraint(equalTo: guide.heightAnchor).isActive = true
    }
    
    public func setupAppTheme() {
        self.backgroundColor = .clear
        trackNumText.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        titleText.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        descriptionText.textColor = AppTheme.shared.colorFor(.STANDART_SUBTEXT)
    }
    
    public func setTrackNum(_ value: Int) {
        trackNumText.text = value > 0 ? "\(value)" : "-"
    }
}
