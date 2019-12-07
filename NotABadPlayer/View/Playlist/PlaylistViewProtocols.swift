//
//  PlaylistViewProtocols.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol BasePlaylistViewDataSource : UICollectionViewDataSource {
    var headerSize: CGSize { get }
    
    func playSelectionAnimation()
}

protocol BasePlaylistViewActionDelegate : NSObject, UICollectionViewDelegate {
    
}
