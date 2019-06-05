//
//  PlayerSeekBar.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 5.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import GTProgressBar

class PlayerSeekBar: UIView
{
    public static let MAX_VALUE: Double = 100
    
    public var onSeekCallback: (Double)->Void = {(percentage) in }
    
    public var progressValue: Double {
        get {
            return Double(progressBar.progress)
        }
        
        set {
            progressBar.progress = CGFloat(newValue / PlayerSeekBar.MAX_VALUE)
        }
    }
    
    public var maximumValue: Double {
        get {
            return PlayerSeekBar.MAX_VALUE
        }
    }
    
    private let progressBar: GTProgressBar = {
        let bar = GTProgressBar()
        bar.orientation = .horizontal
        bar.progress = 1
        bar.barFillColor = AppTheme.shared.colorFor(.PLAYER_SEEK_BAR)
        bar.barBackgroundColor = AppTheme.shared.colorFor(.PLAYER_SEEK_BAR_BACKGROUND)
        bar.barBorderColor = AppTheme.shared.colorFor(.PLAYER_SEEK_BAR_BORDER)
        bar.barFillInset = 0
        bar.displayLabel = false
        return bar
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        setup()
    }
    
    private func setup() {
        let guide = self
        
        self.addSubview(progressBar)
        
        // Setup progress bar constraints
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        progressBar.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        progressBar.leftAnchor.constraint(equalTo: guide.leftAnchor).isActive = true
        progressBar.rightAnchor.constraint(equalTo: guide.rightAnchor).isActive = true
        
        // Interaction
        let barTapGesture = UITapGestureRecognizer(target: self, action: #selector(actionSeek(gesture:)))
        barTapGesture.numberOfTapsRequired = 1
        progressBar.addGestureRecognizer(barTapGesture)
        
        let barHoldGesture = UIPanGestureRecognizer(target: self, action: #selector(actionSeek(gesture:)))
        progressBar.addGestureRecognizer(barHoldGesture)
    }
    
    public func setProgress(_ value: Double) {
        progressBar.progress = CGFloat(value)
    }
}

// Actions
extension PlayerSeekBar {
    @objc func actionSeek(gesture: UIGestureRecognizer) {
        let location = gesture.location(in: self.progressBar)
        
        let invertY = abs(location.y - self.progressBar.frame.height)
        
        let percentage = invertY / self.progressBar.frame.height
        
        self.progressBar.progress = percentage
        
        self.onSeekCallback(Double(percentage))
    }
}
