//
//  PlayerView.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

class PlayerView : UIView
{
    public static let MEDIA_BAR_MAX_VALUE: Double = 100
    
    public weak var delegate: BaseViewController?
    
    @IBOutlet weak var primaryStackView: UIStackView!
    
    @IBOutlet weak var upperStackView: UIStackView!
    @IBOutlet weak var artCoverImage: UIImageView!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var playlistText: UILabel!
    @IBOutlet weak var artistText: UILabel!
    @IBOutlet weak var seekBarSlider: UISlider!
    @IBOutlet weak var mediaButtonsStackView: UIStackView!
    @IBOutlet weak var currentTimeText: UILabel!
    @IBOutlet weak var totalDurationText: UILabel!
    @IBOutlet weak var mediaButtonStack: UIStackView!
    @IBOutlet weak var recallMediaButton: UIImageView!
    @IBOutlet weak var previousMediaButton: UIImageView!
    @IBOutlet weak var playMediaButton: UIImageView!
    @IBOutlet weak var nextMediaButton: UIImageView!
    @IBOutlet weak var playOrderMediaButton: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        // Text default values
        self.titleText.text = ""
        self.playlistText.text = ""
        self.artistText.text = ""
        self.currentTimeText.text = "0:00"
        self.totalDurationText.text = "0:00"
        
        setup()
    }
    
    private func setup() {
        let layoutGuide = self.safeAreaLayoutGuide
        let heightAnchor = layoutGuide.heightAnchor
        
        // Constraints - top
        upperStackView.translatesAutoresizingMaskIntoConstraints = false
        upperStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        
        // Constraints - bottom
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        
        mediaButtonsStackView.translatesAutoresizingMaskIntoConstraints = false
        mediaButtonsStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1).isActive = true
        
        mediaButtonStack.translatesAutoresizingMaskIntoConstraints = false
        mediaButtonStack.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.2).isActive = true
        
        // User input
        let gestureSeekBar = UILongPressGestureRecognizer(target: self, action: #selector(seekBarChanged(gesture:)))
        gestureSeekBar.minimumPressDuration = 0
        self.seekBarSlider.isUserInteractionEnabled = true
        self.seekBarSlider.addGestureRecognizer(gestureSeekBar)
        
        var gestureTap = UITapGestureRecognizer(target: self, action: #selector(actionRecall(sender:)))
        gestureTap.numberOfTapsRequired = 1
        self.recallMediaButton.isUserInteractionEnabled = true
        self.recallMediaButton.addGestureRecognizer(gestureTap)
        
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
        
        gestureSwipe = UISwipeGestureRecognizer(target: self, action: #selector(actionSwipeDown(sender:)))
        gestureSwipe.direction = .down
        self.addGestureRecognizer(gestureSwipe)
    }
    
    public func updateUIState(player: AudioPlayer, track: AudioTrack) {
        updateMediaInfo(player: player, track: track)
        updateSoftUIState(player: player)
    }
    
    public func updateSoftUIState(player: AudioPlayer) {
        // Seek bar update
        let duration = player.durationSec
        let currentPosition = player.currentPositionSec
        let newSeekBarPosition = (currentPosition / duration) * PlayerView.MEDIA_BAR_MAX_VALUE
        
        if seekBarSlider.value != Float(newSeekBarPosition)
        {
            seekBarSlider.value = Float(newSeekBarPosition)
        }
        
        currentTimeText.text = AudioTrack.secondsToString(currentPosition)
        
        // Play order button update
        updatePlayOrderButtonState(player: player)
        
        // Volume bar update
        
    }
    
    public func updateMediaInfo(player: AudioPlayer, track: AudioTrack) {
        let imageSize = CGSize(width: self.artCoverImage.frame.width, height: self.artCoverImage.frame.height)
        self.artCoverImage.image = track.albumCover?.image(at: imageSize)
        
        self.titleText.text = track.title
        self.playlistText.text = track.albumTitle
        self.artistText.text = track.artist
        
        self.currentTimeText.text = "0:00"
        self.totalDurationText.text = track.duration
        
        // Update play button state
        updatePlayButtonState(player: player)
    }
    
    public func updatePlayButtonState(player: AudioPlayer) {
        if player.isPlaying
        {
            playMediaButton.image = UIImage(named: "media_pause")
        }
        else
        {
            playMediaButton.image = UIImage(named: "media_play")
        }
    }
    
    public func updatePlayOrderButtonState(player: AudioPlayer) {
        if let playlist = player.playlist
        {
            switch playlist.playOrder
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
}

// Actions
extension PlayerView {
    @objc public func seekBarChanged(gesture: UILongPressGestureRecognizer) {
        let minDistance: CGFloat = 2.0
        let pointTapped: CGPoint = gesture.location(in: seekBarSlider)
        let widthOfSlider: CGFloat = seekBarSlider.frame.size.width
        let positionOfSlider: CGPoint = seekBarSlider.frame.origin
        
        // If tap is too near from the slider thumb, cancel
        let thumbPosition = CGFloat((seekBarSlider.value / seekBarSlider.maximumValue)) * widthOfSlider
        let dif = abs(pointTapped.x - thumbPosition)
        
        if dif < minDistance
        {
            return
        }
        
        // Calculate new value
        let newValue = ((pointTapped.x - positionOfSlider.x) * CGFloat(seekBarSlider.maximumValue) / widthOfSlider)
        
        // Notify delegate
        delegate?.onPlayerSeekChanged(positionInPercentage: Double(newValue / 100.0))
    }
    
    @objc public func actionRecall(sender: Any) {
        UIAnimations.animateImageClicked(self.recallMediaButton)
        
        delegate?.onPlayerButtonClick(input: .PLAYER_RECALL)
    }
    
    @objc public func actionPrevious(sender: Any) {
        UIAnimations.animateImageClicked(self.previousMediaButton)
        
        delegate?.onPlayerButtonClick(input: .PLAYER_PREVIOUS_BUTTON)
    }
    
    @objc public func actionPlay(sender: Any) {
        UIAnimations.animateImageClicked(self.playMediaButton)
        
        delegate?.onPlayerButtonClick(input: .PLAYER_PLAY_BUTTON)
    }
    
    @objc public func actionNext(sender: Any) {
        UIAnimations.animateImageClicked(self.nextMediaButton)
        
        delegate?.onPlayerButtonClick(input: .PLAYER_NEXT_BUTTON)
    }
    
    @objc public func actionPlayOrder(sender: Any) {
        UIAnimations.animateImageClicked(self.playOrderMediaButton)
        
        delegate?.onPlayOrderButtonClick()
    }
    
    @objc public func actionSwipeLeft(sender: Any) {
        delegate?.onPlayerButtonClick(input: .PLAYER_SWIPE_LEFT)
    }
    
    @objc public func actionSwipeRight(sender: Any) {
        delegate?.onPlayerButtonClick(input: .PLAYER_SWIPE_RIGHT)
    }
    
    @objc public func actionSwipeDown(sender: Any) {
        self.delegate?.onSwipeDown()
    }
}

// Builder
extension PlayerView {
    class func create(owner: Any) -> PlayerView? {
        let bundle = Bundle.main
        let nibName = String(describing: PlayerView.self)
        let nib = UINib(nibName: nibName, bundle: bundle)
        
        return nib.instantiate(withOwner: owner, options: nil).first as? PlayerView
    }
}

// Slider
extension UISlider {
    override open func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        return true
    }
}
