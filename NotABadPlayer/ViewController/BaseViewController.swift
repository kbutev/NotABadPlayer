//
//  BaseViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 8.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

protocol BaseViewController : class {
    func goBack()
    func onSwipeUp()
    func onSwipeDown()
    
    func onPlayerSeekChanged(positionInPercentage: Double)
    func onPlayerButtonClick(input: ApplicationInput)
    func onPlayOrderButtonClick()
    func onPlaylistButtonClick()
}
