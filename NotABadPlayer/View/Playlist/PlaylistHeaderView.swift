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
    public static let HEADER_SIZE = CGSize(width: 0, height: 300)
    public static let HEADER_SIZE_IMAGELESS = CGSize(width: 0, height: 64)
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet private weak var artCoverImage: UIImageView?
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var artistText: UILabel!
    @IBOutlet weak var descriptionText: UILabel!
    
    private var test: Bool = false
    
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
        artCoverImage?.translatesAutoresizingMaskIntoConstraints = false
        artCoverImage?.centerXAnchor.constraint(equalTo: guide.centerXAnchor).isActive = true
        artCoverImage?.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.7).isActive = true
        
        test = true
    }
    
    public func setupAppTheme() {
        self.backgroundColor = .clear
        titleText.textColor = AppTheme.shared.colorFor(.ALBUM_COVER_TITLE)
        artistText.textColor = AppTheme.shared.colorFor(.ALBUM_COVER_ARTIST)
        descriptionText.textColor = AppTheme.shared.colorFor(.ALBUM_COVER_DESCRIPTION)
    }
    
    public func setArtCoverImage(_ image: UIImage) {
        self.artCoverImage?.image = image
    }
    
    public func removeArtCoverImage() {
        if let coverImage = self.artCoverImage {
            coverImage.image = nil
            stackView.removeArrangedSubview(coverImage)
            coverImage.removeFromSuperview()
        }
    }
}
