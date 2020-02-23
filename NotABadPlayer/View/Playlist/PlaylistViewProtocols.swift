//
//  PlaylistViewProtocols.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol BasePlaylistViewDataSource : UICollectionViewDataSource {
    var highlightedChecker : BasePlaylistHighlighedChecker? { get set }
    var favoritesChecker : BasePlaylistFavoritesChecker? { get set }
    var headerSize: CGSize { get }
    var animateHighlightedCells : Bool { get set }
    
    func playSelectionAnimation()
}

protocol BasePlaylistViewActionDelegate : AnyObject, UICollectionViewDelegate {
    
}

protocol BasePlaylistHighlighedChecker : AnyObject {
    func shouldBeHighlighed(item: BaseAudioTrack) -> Bool
}

protocol BasePlaylistFavoritesChecker : AnyObject {
    func isMarkedFavorite(item: BaseAudioTrack) -> Bool
}
