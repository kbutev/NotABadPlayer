//
//  AlbumsTableCell.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 30.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class AlbumsCell : UICollectionViewCell
{
    @IBOutlet weak var covertArtImage: UIImageView!
    @IBOutlet weak var titleText: UILabel!
    
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
        covertArtImage.translatesAutoresizingMaskIntoConstraints = false
        covertArtImage.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        covertArtImage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        covertArtImage.bottomAnchor.constraint(equalTo: titleText.topAnchor).isActive = true
        
        titleText.translatesAutoresizingMaskIntoConstraints = false
        titleText.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        titleText.heightAnchor.constraint(equalToConstant: 50).isActive = true
        titleText.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
    }
}
