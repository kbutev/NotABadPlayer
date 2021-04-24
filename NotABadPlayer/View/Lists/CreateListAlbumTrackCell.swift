//
//  CreateListAlbumTrackCell.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 3.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class CreateListAlbumTrackCell: UITableViewCell
{
    public static let CELL_IDENTIFIER = "cell"
    public static let HEIGHT: CGFloat = 32
    
    var selectedBackground: UIView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Not implemented decode()")
    }
    
    override func awakeFromNib() {
        self.selectedBackground = UIView()
        self.selectedBackground.backgroundColor = AppTheme.shared.colorFor(.CREATE_LIST_SELECTED_TRACK)
        
        setup()
    }
    
    private func setup() {
        // App theme setup
        setupAppTheme()
    }
    
    public func setupAppTheme() {
        self.backgroundColor = .clear
        selectedBackgroundView = selectedBackground
        titleLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
        descriptionLabel.textColor = AppTheme.shared.colorFor(.STANDART_SUBTEXT)
    }
}
