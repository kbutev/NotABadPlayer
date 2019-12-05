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
    
    public var onPlayerSeekCallback: (Double)->Void = {(percentage) in }
    public var onPlayerButtonClickCallback: (ApplicationInput)->Void = {(input) in }
    public var onPlayOrderButtonClickCallback: ()->Void = {() in }
    public var onSwipeDownCallback: ()->Void = {() in }
    public var onSideVolumeBarSeekCallback: (Double)->Void = {(percentage) in }
    public var onSideVolumeBarSpeakerButtonClickCallback: ()->Void = {() in }
    
    @IBOutlet weak var primaryStackView: UIStackView!
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var artCoverImage: UIImageView!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    
    @IBOutlet weak var textLayoutView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var playlistLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    
    @IBOutlet weak var mediaSeekLayout: UIView!
    @IBOutlet weak var seekBar: PlayerSeekBar!
    @IBOutlet weak var seekTimeStackView: UIStackView!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var totalDurationLabel: UILabel!
    
    @IBOutlet weak var mediaButtonStack: UIStackView!
    @IBOutlet weak var recallMediaButton: UIImageView!
    @IBOutlet weak var previousMediaButton: UIImageView!
    @IBOutlet weak var playMediaButton: UIImageView!
    @IBOutlet weak var nextMediaButton: UIImageView!
    @IBOutlet weak var playOrderMediaButton: UIImageView!
    
    private var sideVolumeBar: PlayerSideVolumeBar?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        // Text default values
        self.titleLabel.text = ""
        self.playlistLabel.text = ""
        self.artistLabel.text = ""
        self.currentTimeLabel.text = Text.value(.ZeroTimer)
        self.totalDurationLabel.text = Text.value(.ZeroTimer)
        
        setup()
    }
    
    private func setup() {
        let heightAnchor = primaryStackView.heightAnchor
        
        // App theme setup
        setupAppTheme()
        
        // Top stack setup
        topStackView.translatesAutoresizingMaskIntoConstraints = false
        topStackView.widthAnchor.constraint(equalTo: primaryStackView.widthAnchor).isActive = true
        topStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        
        // Bottom stack setup
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.widthAnchor.constraint(equalTo: primaryStackView.widthAnchor).isActive = true
        bottomStackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.5).isActive = true
        
        // Text layout setup (is inside the bottom stack)
        textLayoutView.translatesAutoresizingMaskIntoConstraints = false
        textLayoutView.widthAnchor.constraint(equalTo: bottomStackView.widthAnchor).isActive = true
        textLayoutView.heightAnchor.constraint(equalTo: bottomStackView.heightAnchor, multiplier: 0.3).isActive = true
        
        // Media seek layout setup (is inside the bottom stack)
        mediaSeekLayout.translatesAutoresizingMaskIntoConstraints = false
        mediaSeekLayout.widthAnchor.constraint(equalTo: bottomStackView.widthAnchor).isActive = true
        mediaSeekLayout.heightAnchor.constraint(equalTo: bottomStackView.heightAnchor, multiplier: 0.4).isActive = true
        
        // Media buttons stack setup (is inside the bottom stack)
        mediaButtonStack.translatesAutoresizingMaskIntoConstraints = false
        mediaButtonStack.widthAnchor.constraint(equalTo: bottomStackView.widthAnchor).isActive = true
        mediaButtonStack.heightAnchor.constraint(equalTo: bottomStackView.heightAnchor, multiplier: 0.3).isActive = true
        
        // Title label setup
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: textLayoutView.topAnchor).isActive = true
        titleLabel.widthAnchor.constraint(equalTo: textLayoutView.widthAnchor).isActive = true
        
        // Playlist label setup
        playlistLabel.translatesAutoresizingMaskIntoConstraints = false
        playlistLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor).isActive = true
        playlistLabel.widthAnchor.constraint(equalTo: textLayoutView.widthAnchor).isActive = true
        
        // Artist label setup
        artistLabel.translatesAutoresizingMaskIntoConstraints = false
        artistLabel.topAnchor.constraint(equalTo: playlistLabel.bottomAnchor).isActive = true
        artistLabel.widthAnchor.constraint(equalTo: textLayoutView.widthAnchor).isActive = true
        
        // Seek bar setup
        seekBar.translatesAutoresizingMaskIntoConstraints = false
        seekBar.widthAnchor.constraint(equalTo: mediaSeekLayout.widthAnchor).isActive = true
        seekBar.bottomAnchor.constraint(equalTo: seekTimeStackView.topAnchor).isActive = true
        
        // Seek time stack setup
        seekTimeStackView.translatesAutoresizingMaskIntoConstraints = false
        seekTimeStackView.widthAnchor.constraint(equalTo: mediaSeekLayout.widthAnchor).isActive = true
        seekTimeStackView.bottomAnchor.constraint(equalTo: mediaSeekLayout.bottomAnchor).isActive = true
        
        // User input setup
        seekBar.onSeekCallback = {[weak self] (progress) in
            self?.onPlayerSeekCallback(progress)
        }
        
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
    
    public func setupAppTheme() {
        self.backgroundColor = AppTheme.shared.colorFor(.PLAYER_BACKGROUND)
        
        textLayoutView.backgroundColor = .clear
        
        titleLabel.textColor = AppTheme.shared.colorFor(.PLAYER_TRACK_TITLE)
        playlistLabel.textColor = AppTheme.shared.colorFor(.PLAYER_PLAYLIST_TITLE)
        artistLabel.textColor = AppTheme.shared.colorFor(.PLAYER_ARTIST)
        
        mediaSeekLayout.backgroundColor = .clear
        
        currentTimeLabel.textColor = AppTheme.shared.colorFor(.PLAYER_TEXT)
        totalDurationLabel.textColor = AppTheme.shared.colorFor(.PLAYER_TEXT)
        
        recallMediaButton.tintColor = AppTheme.shared.colorFor(.PLAYER_BUTTON)
        previousMediaButton.tintColor = AppTheme.shared.colorFor(.PLAYER_BUTTON)
        playMediaButton.tintColor = AppTheme.shared.colorFor(.PLAYER_BUTTON)
        nextMediaButton.tintColor = AppTheme.shared.colorFor(.PLAYER_BUTTON)
        playOrderMediaButton.tintColor = AppTheme.shared.colorFor(.PLAYER_BUTTON)
    }
    
    public func enableVolumeBar(leftSide: Bool) {
        if sideVolumeBar != nil
        {
            return
        }
        
        // Create and add
        let volumeBar = PlayerSideVolumeBar(frame: .zero)
        let emptySpace = UIView()
        emptySpace.backgroundColor = .clear
        
        if leftSide
        {
            topStackView.insertArrangedSubview(volumeBar, at: 0)
            topStackView.addArrangedSubview(emptySpace)
        }
        else
        {
            topStackView.addArrangedSubview(volumeBar)
            topStackView.insertArrangedSubview(emptySpace, at: 0)
        }
        
        // Setup volume bar
        sideVolumeBar = volumeBar
        volumeBar.translatesAutoresizingMaskIntoConstraints = false
        volumeBar.topAnchor.constraint(equalTo: topStackView.topAnchor).isActive = true
        volumeBar.widthAnchor.constraint(equalToConstant: PlayerSideVolumeBar.SIZE.width).isActive = true
        volumeBar.heightAnchor.constraint(equalTo: topStackView.heightAnchor).isActive = true
        
        // Setup empty space
        emptySpace.translatesAutoresizingMaskIntoConstraints = false
        emptySpace.topAnchor.constraint(equalTo: topStackView.topAnchor).isActive = true
        emptySpace.widthAnchor.constraint(equalToConstant: PlayerSideVolumeBar.SIZE.width).isActive = true
        emptySpace.heightAnchor.constraint(equalTo: topStackView.heightAnchor).isActive = true
        
        // Interaction
        sideVolumeBar?.onVolumeSeekCallback = {[weak self] (percentage) -> Void in
            self?.onSideVolumeBarSeekCallback(percentage)
        }
        
        sideVolumeBar?.onSpeakerButtonClickCallback = {[weak self] () -> Void in
            self?.onSideVolumeBarSpeakerButtonClickCallback()
        }
    }
    
    public func updateUIState(player: AudioPlayer, track: AudioTrack) {
        updateMediaInfo(player: player, track: track)
        updateSoftUIState(player: player)
    }
    
    public func updateSoftUIState(player: AudioPlayer) {
        guard let seekBar = self.seekBar else {
            return
        }
        
        // Seek bar update
        let duration = player.durationSec
        let currentPosition = player.currentPositionSec
        let newSeekBarPosition = (currentPosition / duration) * PlayerView.MEDIA_BAR_MAX_VALUE
        
        if seekBar.progressValue != newSeekBarPosition
        {
            seekBar.progressValue = newSeekBarPosition
        }
        
        currentTimeLabel.text = StringUtilities.secondsToString(currentPosition)
        
        // Play order button update
        updatePlayOrderButtonState(order: player.playOrder)
    }
    
    public func updateMediaInfo(player: AudioPlayer, track: AudioTrack) {
        let imageSize = CGSize(width: self.artCoverImage.frame.width, height: self.artCoverImage.frame.height)
        self.artCoverImage.image = track.albumCoverImage
        
        self.titleLabel.text = track.title
        self.playlistLabel.text = track.albumTitle
        self.artistLabel.text = track.artist
        
        self.totalDurationLabel.text = track.duration
        
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
    
    public func updatePlayOrderButtonState(order: AudioPlayOrder) {
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
    
    public func onSystemVolumeChanged(_ value: Double) {
        if let bar = sideVolumeBar
        {
            bar.setProgress(value)
        }
    }
}

// Actions
extension PlayerView {
    @objc public func actionRecall(sender: Any) {
        UIAnimations.animateImageClicked(self.recallMediaButton)
        
        self.onPlayerButtonClickCallback(.PLAYER_RECALL)
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
    
    @objc public func actionSwipeDown(sender: Any) {
        self.onSwipeDownCallback()
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
