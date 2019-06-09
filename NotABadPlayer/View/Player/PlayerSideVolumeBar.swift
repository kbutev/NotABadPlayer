//
//  PlayerSideVolumeBar.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 5.06.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import GTProgressBar

class PlayerSideVolumeBar: UIStackView
{
    public static let SIZE = CGSize(width: 23, height: 200)
    public static let VOLUME_BAR_MAX_VALUE: Double = 100
    
    public static let SPEAKER_BUTTON_SIZE = CGSize(width: 23, height: 48)
    
    public var onVolumeSeekCallback: (Double)->Void = {(percentage) in }
    public var onSpeakerButtonClickCallback: ()->Void = {() in }
    
    private let progressBar: GTProgressBar = {
        let bar = GTProgressBar()
        bar.orientation = .vertical
        bar.progress = 1
        bar.barFillColor = Colors.BLUE
        bar.displayLabel = false
        return bar
    }()
    
    private let speakerButton: UIImageView = UIImageView(image: UIImage(named: "media_volume"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func didMoveToSuperview() {
        setup()
    }
    
    private func setup() {
        let guide = self
        
        self.axis = .vertical
        
        self.addArrangedSubview(progressBar)
        self.addArrangedSubview(speakerButton)
        
        // Setup progress bar
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        progressBar.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
        progressBar.bottomAnchor.constraint(equalTo: speakerButton.topAnchor).isActive = true
        progressBar.widthAnchor.constraint(equalTo: guide.widthAnchor).isActive = true
        
        // Setup speaker icon
        speakerButton.contentMode = .scaleAspectFit
        speakerButton.translatesAutoresizingMaskIntoConstraints = false
        speakerButton.widthAnchor.constraint(equalTo: guide.widthAnchor).isActive = true
        speakerButton.heightAnchor.constraint(equalToConstant: PlayerSideVolumeBar.SPEAKER_BUTTON_SIZE.height).isActive = true
        
        // Interaction
        let barTapGesture = UITapGestureRecognizer(target: self, action: #selector(actionVolumeBarSeek(gesture:)))
        barTapGesture.numberOfTapsRequired = 1
        progressBar.addGestureRecognizer(barTapGesture)
        
        let barHoldGesture = UIPanGestureRecognizer(target: self, action: #selector(actionVolumeBarSeek(gesture:)))
        progressBar.addGestureRecognizer(barHoldGesture)
        
        progressBar.isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionVolumeSpeakerClick(gesture:)))
        tapGesture.numberOfTapsRequired = 1
        speakerButton.addGestureRecognizer(tapGesture)
        speakerButton.isUserInteractionEnabled = true
    }
    
    public func setProgress(_ value: Double) {
        progressBar.progress = CGFloat(value)
    }
}

// Actions
extension PlayerSideVolumeBar {
    @objc func actionVolumeBarSeek(gesture: UIGestureRecognizer) {
        let location = gesture.location(in: self.progressBar)
        
        let invertY = abs(location.y - self.progressBar.frame.height)
        
        let percentage = invertY / self.progressBar.frame.height
        
        self.progressBar.progress = percentage
        
        self.onVolumeSeekCallback(Double(percentage) * PlayerSideVolumeBar.VOLUME_BAR_MAX_VALUE)
    }
    
    @objc func actionVolumeSpeakerClick(gesture: UIGestureRecognizer) {
        UIAnimations.animateImageClicked(self.speakerButton)
        
        self.onSpeakerButtonClickCallback()
    }
}
