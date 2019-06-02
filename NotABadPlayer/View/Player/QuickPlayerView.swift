//
//  QuickPlayerView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 13.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class QuickPlayerView : UIView
{
    public static let MEDIA_BAR_MAX_VALUE: Double = 100
    
    private var initialized: Bool = false
    
    public var onPlaylistButtonClickCallback: ()->() = {() in }
    public var onPlayerButtonClickCallback: (ApplicationInput)->() = {(input) in }
    public var onPlayOrderButtonClickCallback: ()->() = {() in }
    public var onSwipeUpCallback: ()->() = {() in }
    
    @IBOutlet var primaryStackView: UIStackView!
    
    @IBOutlet var trackInfoStackView: UIStackView!
    @IBOutlet var trackInfoArtCoverImage: UIImageView!
    @IBOutlet var trackInfoTextStackView: UIStackView!
    @IBOutlet var trackInfoTitleText: UILabel!
    @IBOutlet var trackInfoDurationText: UILabel!
    
    @IBOutlet var mediaButtonsStackView: UIStackView!
    @IBOutlet var playlistMediaButton: UIImageView!
    @IBOutlet var previousMediaButton: UIImageView!
    @IBOutlet var playMediaButton: UIImageView!
    @IBOutlet var nextMediaButton: UIImageView!
    @IBOutlet var playOrderMediaButton: UIImageView!
    
    @IBOutlet var trackSeekBarSlider: UISlider!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        // Text default values
        trackInfoTitleText.text = Text.value(.NothingPlaying)
        trackInfoDurationText.text = Text.value(.DoubleZeroTimers)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        if !initialized
        {
            initialized = true
            setup()
        }
    }
    
    private func setup() {
        let guide = primaryStackView!
        
        // Constraints
        primaryStackView.translatesAutoresizingMaskIntoConstraints = false
        primaryStackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        primaryStackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        primaryStackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        primaryStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        // Constraints - track info stack
        trackInfoArtCoverImage.translatesAutoresizingMaskIntoConstraints = false
        trackInfoArtCoverImage.widthAnchor.constraint(equalToConstant: 64).isActive = true
        
        // Constraints - media stack
        mediaButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        mediaButtonsStackView.heightAnchor.constraint(equalTo: guide.heightAnchor, multiplier: 0.5).isActive = true
        
        trackSeekBarSlider.translatesAutoresizingMaskIntoConstraints = false
        trackSeekBarSlider.heightAnchor.constraint(equalToConstant: 8).isActive = true
        
        // Customize seek bar
        trackSeekBarSlider.setThumbImage(UIImage(), for: .normal)
        
        // User input
        var gestureTap = UITapGestureRecognizer(target: self, action: #selector(actionPlaylist(sender:)))
        gestureTap.numberOfTapsRequired = 1
        self.playlistMediaButton.isUserInteractionEnabled = true
        self.playlistMediaButton.addGestureRecognizer(gestureTap)
        
        gestureTap = UITapGestureRecognizer(target: self, action: #selector(actionPrevious(sender:)))
        gestureTap.numberOfTapsRequired = 1
        self.previousMediaButton.isUserInteractionEnabled = true
        self.previousMediaButton.addGestureRecognizer(gestureTap)
        
        gestureTap = UITapGestureRecognizer(target: self, action: #selector(actionPlay(sender:)))
        gestureTap.numberOfTapsRequired = 1
        self.playMediaButton.isUserInteractionEnabled = true
        self.playMediaButton.addGestureRecognizer(gestureTap)
        
        gestureTap = UITapGestureRecognizer(target: self, action: #selector(actionNext(sender:)))
        gestureTap.numberOfTapsRequired = 1
        self.nextMediaButton.isUserInteractionEnabled = true
        self.nextMediaButton.addGestureRecognizer(gestureTap)
        
        gestureTap = UITapGestureRecognizer(target: self, action: #selector(actionPlayOrder(sender:)))
        gestureTap.numberOfTapsRequired = 1
        self.playOrderMediaButton.isUserInteractionEnabled = true
        self.playOrderMediaButton.addGestureRecognizer(gestureTap)
        
        var gestureSwipe = UISwipeGestureRecognizer(target: self, action: #selector(actionSwipeLeft(sender:)))
        gestureSwipe.direction = .left
        self.addGestureRecognizer(gestureSwipe)
        
        gestureSwipe = UISwipeGestureRecognizer(target: self, action: #selector(actionSwipeRight(sender:)))
        gestureSwipe.direction = .right
        self.addGestureRecognizer(gestureSwipe)
        
        gestureSwipe = UISwipeGestureRecognizer(target: self, action: #selector(actionSwipeUp(sender:)))
        gestureSwipe.direction = .up
        self.addGestureRecognizer(gestureSwipe)
    }
    
    func updateTime(currentTime: Double, totalDuration: Double) {
        trackInfoDurationText.text = "\(AudioTrack.secondsToString(currentTime))/\(AudioTrack.secondsToString(totalDuration))"
        
        // Seek bar update
        let newSeekBarPosition = (currentTime / totalDuration) * QuickPlayerView.MEDIA_BAR_MAX_VALUE
        
        if trackSeekBarSlider.value != Float(newSeekBarPosition)
        {
            trackSeekBarSlider.value = Float(newSeekBarPosition)
        }
    }
    
    func updateMediaInfo(track: AudioTrack) {
        trackInfoArtCoverImage.image = track.albumCover?.image(at: trackInfoArtCoverImage!.frame.size)
        trackInfoTitleText.text = track.title
    }
    
    func updatePlayButtonState(playing: Bool) {
        if playing
        {
            playMediaButton.image = UIImage(named: "media_pause")
        }
        else
        {
            playMediaButton.image = UIImage(named: "media_play")
        }
    }
    
    func updatePlayOrderButtonState(order: AudioPlayOrder) {
        switch order
        {
        case .FORWARDS:
            playOrderMediaButton.image = UIImage(named: "media_order_forwards")
            break
        case .FORWARDS_REPEAT:
            playOrderMediaButton.image = UIImage(named: "media_order_forwards_repeat")
            break
        case .ONCE_FOREVER:
            playOrderMediaButton.image = UIImage(named: "media_order_repeat_forever")
            break
        case .SHUFFLE:
            playOrderMediaButton.image = UIImage(named: "media_order_shuffle")
            break
        default:
            playOrderMediaButton.image = UIImage(named: "media_order_forwards")
            break
        }
    }
}

// Actions
extension QuickPlayerView {
    @objc public func actionPlaylist(sender: Any) {
        UIAnimations.animateImageClicked(self.playlistMediaButton)
        
        self.onPlaylistButtonClickCallback()
    }
    
    @objc public func actionPrevious(sender: Any) {
        UIAnimations.animateImageClicked(self.previousMediaButton)
        
        self.onPlayerButtonClickCallback(.PLAYER_PREVIOUS_BUTTON)
    }
    
    @objc public func actionPlay(sender: Any) {
        UIAnimations.animateImageClicked(self.playMediaButton)
        
        self.onPlayerButtonClickCallback(.PLAYER_PLAY_BUTTON)
    }
    
    @objc public func actionNext(sender: Any) {
        UIAnimations.animateImageClicked(self.nextMediaButton)
        
        self.onPlayerButtonClickCallback(.PLAYER_NEXT_BUTTON)
    }
    
    @objc public func actionPlayOrder(sender: Any) {
        UIAnimations.animateImageClicked(self.playOrderMediaButton)
        
        self.onPlayOrderButtonClickCallback()
    }
    
    @objc public func actionSwipeLeft(sender: Any) {
        self.onPlayerButtonClickCallback(.PLAYER_SWIPE_LEFT)
    }
    
    @objc public func actionSwipeRight(sender: Any) {
        self.onPlayerButtonClickCallback(.PLAYER_SWIPE_RIGHT)
    }
    
    @objc public func actionSwipeUp(sender: Any) {
        self.onSwipeUpCallback()
    }
}

// Builder
extension QuickPlayerView {
    class func create(owner: Any) -> QuickPlayerView? {
        let bundle = Bundle.main
        let nibName = String(describing: QuickPlayerView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? QuickPlayerView
    }
}
