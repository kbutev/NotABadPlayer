//
//  CreateListAddedTrackCell.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 3.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class CreateListAddedTrackCell: UITableViewCell
{
    public static let SIZE = CGSize(width: 0, height: 48)
    
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var coverImage: UIImageView!
    @IBOutlet var textStackView: UIStackView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    
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
        coverImage.translatesAutoresizingMaskIntoConstraints = false
        coverImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        coverImage.heightAnchor.constraint(equalToConstant: CreateListAddedTrackCell.SIZE.height).isActive = true
        
        textStackView.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 0)
        textStackView.isLayoutMarginsRelativeArrangement = true
    }
}
