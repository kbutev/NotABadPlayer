//
//  NBPMarqueeLabel.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 29.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import MarqueeLabel

class NBPMarqueeLabel: MarqueeLabel {
    public static let DEFAULT_SCROLL_DURATION: CGFloat = 10
    public static let DEFAULT_SPACING_BETWEEN_TRANSITIONS: CGFloat = 40.0
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.backgroundColor = .clear
        self.fadeLength = NBPMarqueeLabel.DEFAULT_SPACING_BETWEEN_TRANSITIONS
        self.speed = .duration(NBPMarqueeLabel.DEFAULT_SCROLL_DURATION)
    }
}
