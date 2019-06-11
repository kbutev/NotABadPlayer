//
//  ListsItemCell.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 2.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class ListsItemCell : UITableViewCell
{
    public static let CELL_IDENTIFIER = "cell"
    public static let HEIGHT: CGFloat = 64
    
    @IBOutlet weak var primaryStackView: UIStackView!
    @IBOutlet weak var artCoverImage: UIImageView!
    @IBOutlet weak var textStackView: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
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
        
        // Art cover setup
        artCoverImage.translatesAutoresizingMaskIntoConstraints = false
        artCoverImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        artCoverImage.heightAnchor.constraint(equalTo: guide.heightAnchor).isActive = true
        
        // Text stack setup
        textStackView.layoutMargins = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 0)
        textStackView.isLayoutMarginsRelativeArrangement = true
        
        // Text labels setup
        titleLabel.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
    }
    
    public func setupAppTheme() {
        self.backgroundColor = .clear
        descriptionLabel.textColor = AppTheme.shared.colorFor(.STANDART_SUBTEXT)
    }
}
