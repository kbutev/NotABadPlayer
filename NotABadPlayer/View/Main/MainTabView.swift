//
//  MainTabView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 25.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class MainTabView : UIStackView {
    public static let DEFAULT_BUTTON_COLOR: UIColor = .white
    
    var albumsButton: UIImageView!
    var listsButton: UIImageView!
    var searchButton: UIImageView!
    var settingsButton: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        setup()
    }
    
    private func setup() {
        albumsButton = UIImageView(image: UIImage(named: "tab_albums"))
        albumsButton.isUserInteractionEnabled = true
        albumsButton.contentMode = .scaleAspectFit
        albumsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        listsButton = UIImageView(image: UIImage(named: "tab_lists"))
        listsButton.isUserInteractionEnabled = true
        listsButton.contentMode = .scaleAspectFit
        listsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        searchButton = UIImageView(image: UIImage(named: "tab_search"))
        searchButton.isUserInteractionEnabled = true
        searchButton.contentMode = .scaleAspectFit
        searchButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        settingsButton = UIImageView(image: UIImage(named: "tab_settings"))
        settingsButton.isUserInteractionEnabled = true
        settingsButton.contentMode = .scaleAspectFit
        settingsButton.tintColor = MainTabView.DEFAULT_BUTTON_COLOR
        
        self.addArrangedSubview(albumsButton)
        self.addArrangedSubview(listsButton)
        self.addArrangedSubview(searchButton)
        self.addArrangedSubview(settingsButton)
    }
}
