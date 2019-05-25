//
//  PlaylistHeaderView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class PlaylistHeaderView : UICollectionReusableView
{
    @IBOutlet var stackView: UIStackView!
    @IBOutlet var artCoverImage: UIImageView!
    @IBOutlet var titleText: UILabel!
    @IBOutlet var artistText: UILabel!
    @IBOutlet var descriptionText: UILabel!
    
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
        let guide = stackView!
        
        artCoverImage.translatesAutoresizingMaskIntoConstraints = false
        artCoverImage.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        artCoverImage.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.7).isActive = true
        
        titleText.translatesAutoresizingMaskIntoConstraints = false
        titleText.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        titleText.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.1).isActive = true
        
        artistText.translatesAutoresizingMaskIntoConstraints = false
        artistText.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        artistText.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.1).isActive = true
        
        descriptionText.translatesAutoresizingMaskIntoConstraints = false
        descriptionText.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        descriptionText.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.1).isActive = true
    }
}
