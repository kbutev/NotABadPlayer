//
//  SearchItemCell.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 29.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class SearchItemCell : UICollectionViewCell
{
    @IBOutlet weak var horizontalStackView: UIStackView!
    @IBOutlet weak var trackAlbumCover: UIImageView!
    
    @IBOutlet weak var verticalStackView: UIStackView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var albumTitle: UILabel!
    @IBOutlet weak var durationText: UILabel!
    
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
        
        trackAlbumCover.translatesAutoresizingMaskIntoConstraints = false
        trackAlbumCover.widthAnchor.constraint(equalToConstant: 48).isActive = true
        trackAlbumCover.heightAnchor.constraint(equalTo: guide.heightAnchor).isActive = true
        
        verticalStackView.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        verticalStackView.isLayoutMarginsRelativeArrangement = true
    }
}
