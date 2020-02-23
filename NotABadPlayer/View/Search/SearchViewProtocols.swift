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
    var highlightedChecker : BaseSearchHighlighedChecker? { get set }
    var favoritesChecker : BaseSearchFavoritesChecker? { get set }
    
    var animateHighlightedCells : Bool { get set }
    
    func playSelectionAnimation()
}

protocol BaseSearchViewActionDelegate : UICollectionViewDelegate {
    
}

protocol BaseSearchHighlighedChecker : AnyObject {
    func shouldBeHighlighed(item: BaseAudioTrack) -> Bool
}

protocol BaseSearchFavoritesChecker : AnyObject {
    func isMarkedFavorite(item: BaseAudioTrack) -> Bool
}
