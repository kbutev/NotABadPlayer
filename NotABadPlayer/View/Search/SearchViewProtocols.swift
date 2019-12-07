//
//  SearchViewProtocols.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol BaseSearchViewDataSource : UICollectionViewDataSource
{
    func playSelectionAnimation()
}

protocol BaseSearchViewActionDelegate : UICollectionViewDelegate {
    
}
