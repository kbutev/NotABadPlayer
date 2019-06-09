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
    public static let HEADER_SIZE = CGSize(width: 0, height: 224)
    public static let HEADER_SIZE_IMAGELESS = CGSize(width: 0, height: 64)
    
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
        
        // App theme setup
        setupAppTheme()
        
        // Art cover setup
        artCoverImage.translatesAutoresizingMaskIntoConstraints = false
        artCoverImage.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        artCoverImage.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.7).isActive = true
    }
    
    public func setupAppTheme() {
        self.backgroundColor = .clear
        titleText.textColor = AppTheme.shared.colorFor(.ALBUM_COVER_TITLE)
        artistText.textColor = AppTheme.shared.colorFor(.ALBUM_COVER_ARTIST)
        descriptionText.textColor = AppTheme.shared.colorFor(.ALBUM_COVER_DESCRIPTION)
    }
    
    public func removeArtCoverImage() {
        artCoverImage.image = nil
        stackView.removeArrangedSubview(artCoverImage)
        artCoverImage.removeFromSuperview()
    }
}
