//
//  SearchViewProtocols.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol SearchViewDataSource : UICollectionViewDataSource {
    var highlightedChecker : SearchHighlighedChecker? { get set }
    var favoritesChecker : SearchFavoritesChecker? { get set }
    
    var animateHighlightedCells : Bool { get set }
    
    func playSelectionAnimation()
}

protocol SearchViewActionDelegate : UICollectionViewDelegate {
    
}

protocol SearchHighlighedChecker : AnyObject {
    func shouldBeHighlighed(item: AudioTrackProtocol) -> Bool
}

protocol SearchFavoritesChecker : AnyObject {
    func isMarkedFavorite(item: AudioTrackProtocol) -> Bool
}
