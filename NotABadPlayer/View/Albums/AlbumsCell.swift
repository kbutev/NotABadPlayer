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
    public static let CELL_IDENTIFIER = "cell"
    public static let SIZE = CGSize(width: 0, height: 256)
    public static let COVER_SIZE = CGSize(width: AlbumsCell.SIZE.width, height: AlbumsCell.SIZE.height - AlbumsCell.TEXT_SIZE.height)
    public static let TEXT_SIZE = CGSize(width: AlbumsCell.SIZE.width, height: 52)
    public static let INBETWEEN_SPACING: CGFloat = 2
    
    @IBOutlet weak var coverArtImage: UIImageView!
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
        // App theme setup
        setupAppTheme()
        
        // Cover art setup
        coverArtImage.translatesAutoresizingMaskIntoConstraints = false
        coverArtImage.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        coverArtImage.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        coverArtImage.heightAnchor.constraint(equalToConstant: AlbumsCell.COVER_SIZE.height).isActive = true
        
        // Title setup
        titleText.translatesAutoresizingMaskIntoConstraints = false
        titleText.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        titleText.topAnchor.constraint(equalTo: coverArtImage.bottomAnchor, constant: AlbumsCell.INBETWEEN_SPACING).isActive = true
    }
    
    public func setupAppTheme() {
        
        self.backgroundColor = .clear
        titleText.textColor = AppTheme.shared.colorFor(.STANDART_TEXT)
    }
}
