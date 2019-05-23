//
//  PlayerViewController.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit

protocol PlayerViewDelegate : class {
    func updatePlayerScreen(playlist: AudioPlaylist)
    
    func onErrorEncountered(message: String)
}

class PlayerViewController: UIViewController, BaseViewController {
    private var baseView: PlayerView?
    
    public var presenter: BasePresenter?
    
    private var encounteredError: String?
    
    init(withPresenter presenter: BasePresenter) {
        self.presenter = presenter
        
        super.init(nibName: String(describing: PlayerViewController.self), bundle: Bundle.main)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func loadView() {
        self.baseView = PlayerView.create(owner: self)
        self.view = self.baseView
        self.baseView?.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.start()
        
        AudioPlayer.shared.attach(observer: self)
        
        Looper.shared.subscribe(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if any errors have been encountered
        if let error = encounteredError
        {
            AlertWindows.shared.show(sourceVC: self, withTitle: "Error", withDescription: error, actionText: "Ok", action: {(action: UIAlertAction) in
                self.goBack()
            })
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        Looper.shared.unsubscribe(self)
        
        AudioPlayer.shared.detach(observer: self)
    }
    
    func goBack() {
        NavigationHelpers.removeVC(self)
    }
    
    func onSwipeUp() {
        
    }
    
    func onSwipeDown() {
        self.goBack()
    }
    
    func onPlayerSeekChanged(positionInPercentage: Double) {
        let duration = AudioPlayer.shared.durationSec
        
        AudioPlayer.shared.seekTo(seconds: duration * positionInPercentage)
    }
    
    func onPlayerButtonClick(input: ApplicationInput) {
        presenter?.onPlayerButtonClick(input: input)
    }
    
    func onPlayOrderButtonClick() {
        presenter?.onPlayOrderButtonClick()
    }
    
    func onPlaylistButtonClick() {
        presenter?.onOpenPlaylistButtonClick()
    }
}

extension PlayerViewController : PlayerViewDelegate {
    func updatePlayerScreen(playlist: AudioPlaylist) {
        self.baseView?.updateUIState(player: AudioPlayer.shared, track: playlist.playingTrack)
    }
    
    func onErrorEncountered(message: String) {
        self.encounteredError = message
    }
}

extension PlayerViewController : AudioPlayerObserver {
    func onPlayerPlay(current: AudioTrack) {
        self.baseView?.updateUIState(player: AudioPlayer.shared, track: current)
    }
    
    func onPlayerFinish() {
        self.baseView?.updatePlayButtonState(player: AudioPlayer.shared)
    }
    
    func onPlayerStop() {
        self.baseView?.updatePlayButtonState(player: AudioPlayer.shared)
    }
    
    func onPlayerPause(track: AudioTrack) {
        self.baseView?.updatePlayButtonState(player: AudioPlayer.shared)
    }
    
    func onPlayerResume(track: AudioTrack) {
        self.baseView?.updatePlayButtonState(player: AudioPlayer.shared)
    }
    
    func onPlayOrderChange(order: AudioPlayOrder) {
        self.baseView?.updatePlayOrderButtonState(order: order)
    }
}

extension PlayerViewController : LooperClient {
    func loop() {
        baseView?.updateSoftUIState(player: AudioPlayer.shared)
    }
}
