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
    public static let SIZE: CGSize = CGSize(width: 0, height: 28)
    public static let MAX_VALUE: Double = 100
    public static let HORIZONTAL_MARGIN: CGFloat = 10
    public static let THUMB_SIZE: CGSize = CGSize(width: 16, height: 28)
    
    public var onSeekCallback: (Double)->Void = {(percentage) in }
    
    public var progressValue: Double {
        get {
            return Double(progressBar.progress)
        }
        
        set {
            progressBar.progress = CGFloat(newValue / PlayerSeekBar.MAX_VALUE)
            
            self.updateThumbView()
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
        bar.barBorderWidth = 1
        bar.barFillInset = 0
        bar.cornerType = GTProgressBarCornerType.square
        bar.displayLabel = false
        return bar
    }()
    
    private let thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = AppTheme.shared.colorFor(.PLAYER_SEEK_BAR_THUMB)
        thumb.layer.borderColor = AppTheme.shared.colorFor(.PLAYER_SEEK_BAR_THUMB_BORDER).cgColor
        thumb.layer.borderWidth = 1
        return thumb
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        setup()
        updateThumbView()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        updateThumbView()
    }
    
    private func setup() {
        let guide = self
        
        // App theme setup
        setupAppTheme()
        
        // Self setup
        self.translatesAutoresizingMaskIntoConstraints = false
        self.heightAnchor.constraint(equalToConstant: PlayerSeekBar.SIZE.height).isActive = true
        
        // Add the views are manually created
        self.addSubview(progressBar)
        self.addSubview(thumbView)
        
        // Progress bar setup
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        progressBar.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
        progressBar.leftAnchor.constraint(equalTo: guide.leftAnchor, constant: PlayerSeekBar.HORIZONTAL_MARGIN).isActive = true
        progressBar.rightAnchor.constraint(equalTo: guide.rightAnchor, constant: -PlayerSeekBar.HORIZONTAL_MARGIN).isActive = true
        
        // Progress bar thumb setup
        thumbView.frame.size.width = PlayerSeekBar.THUMB_SIZE.width
        thumbView.frame.size.height = progressBar.frame.height
        updateThumbView()
        
        // Interaction setup
        let barTapGesture = UITapGestureRecognizer(target: self, action: #selector(actionSeek(gesture:)))
        barTapGesture.numberOfTapsRequired = 1
        progressBar.addGestureRecognizer(barTapGesture)
        
        let barHoldGesture = UIPanGestureRecognizer(target: self, action: #selector(actionSeek(gesture:)))
        progressBar.addGestureRecognizer(barHoldGesture)
    }
    
    public func setupAppTheme() {
        self.backgroundColor = .clear
    }
    
    private func updateThumbView() {
        if thumbView.frame.height != progressBar.frame.height
        {
            thumbView.frame.size.height = progressBar.frame.height
        }
        
        let newX = Int(progressBar.frame.width * progressBar.progress)
        
        thumbView.frame.origin.x = CGFloat(newX)
    }
}

// Actions
extension PlayerSeekBar {
    @objc func actionSeek(gesture: UIGestureRecognizer) {
        let location = gesture.location(in: self.progressBar)
        
        var percentage = location.x / self.progressBar.frame.width
        
        if percentage >= 1.0
        {
            percentage = 0.99
        }
        
        if percentage < 0.0
        {
            percentage = 0
        }
        
        self.progressBar.progress = percentage
        
        self.updateThumbView()
        
        self.onSeekCallback(Double(percentage))
    }
}
