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
    public static let HEIGHT: CGFloat = 64
    
    @IBOutlet weak var primaryStackView: UIStackView!
    @IBOutlet weak var playlistImage: UIImageView!
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
        
        playlistImage.translatesAutoresizingMaskIntoConstraints = false
        playlistImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        playlistImage.heightAnchor.constraint(equalTo: guide.heightAnchor).isActive = true
        
        textStackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        textStackView.isLayoutMarginsRelativeArrangement = true
    }
}
