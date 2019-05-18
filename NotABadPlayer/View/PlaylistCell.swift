//
//  PlaylistCell.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class PlaylistCell : UICollectionViewCell
{
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
        trackNumText.translatesAutoresizingMaskIntoConstraints = false
        trackNumText.widthAnchor.constraint(equalToConstant: 32).isActive = true
        trackNumText.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
    }
}
