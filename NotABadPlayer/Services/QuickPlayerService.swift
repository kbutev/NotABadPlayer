//
//  QuickPlayerService.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

struct QuickPlayerObserverValue
{
    weak var observer : QuickPlayerObserver?
    
    init(_ observer: QuickPlayerObserver)
    {
        self.observer = observer
    }
    
    var value : QuickPlayerObserver? {
        get {
            return observer
        }
    }
}

protocol QuickPlayerObserver : NSObject {
    func updateTime(currentTime: Double, totalDuration: Double)
    func updateMediaInfo(track: AudioTrack)
    func updateButtonsStates(isPlaying: Bool)
    func updatePlayOrderButtonState(playOrder: AudioPlayOrder)
}

struct QuickPlayerAudioState {
    var playOrder: AudioPlayOrder = .FORWARDS
    
    init() {
        
    }
    
    init(player: AudioPlayer) {
        playOrder = player.playlist?.playOrder ?? .FORWARDS
    }
    
    func isStateOutdated(player: AudioPlayer) -> Bool {
        if let playlist = player.playlist
        {
            return playOrder != playlist.playOrder
        }
        
        return false
    }
}

class QuickPlayerService : NSObject {
    public static let LOOP_INTERVAL_SECONDS: Double = 0.5
    
    public static let shared = QuickPlayerService()
    
    private var _audioPlayer: AudioPlayer?
    
    private var audioPlayer: AudioPlayer {
        get {
            checkIfServiceIsInitialized()
            
            return self._audioPlayer!
        }
    }
    
    private var observers: [QuickPlayerObserverValue] = []
    
    private var timer: Timer?
    
    private var audioState: QuickPlayerAudioState = QuickPlayerAudioState()
    
    func initialize(audioPlayer: AudioPlayer) {
        if self.timer != nil
        {
            fatalError("[\(String(describing: QuickPlayerService.self))] is being initialized twice")
        }
        
        self._audioPlayer = audioPlayer
        
        start()
    }
    
    private func start() {
        timer = Timer.scheduledTimer(timeInterval: QuickPlayerService.LOOP_INTERVAL_SECONDS,
                                     target: self,
                                     selector: #selector(loop),
                                     userInfo: nil,
                                     repeats: true)
        
        AudioPlayer.shared.attach(observer: self)
    }
    
    private func checkIfServiceIsInitialized() {
        if self.timer == nil
        {
            fatalError("[\(String(describing: QuickPlayerService.self))] being used before being initialized, initialize() has never been called")
        }
    }
}

// Observers
extension QuickPlayerService {
    func attach(observer: QuickPlayerObserver) {
        observers.append(QuickPlayerObserverValue(observer))
        
        fullyUpdateObserver(observer)
    }
    
    func detach(observer: QuickPlayerObserver) {
        observers.removeAll(where: {(element) -> Bool in
            if let elementValue = element.value
            {
                return elementValue == observer
            }
            
            return false
        })
    }
    
    func fullyUpdateObserver(_ observer: QuickPlayerObserver) {
        let player = AudioPlayer.shared
        
        if let playlist = player.playlist
        {
            let currentTrack = playlist.playingTrack
            
            let currentTime = player.currentPositionSec
            let duration = player.durationSec
            
            observer.updateMediaInfo(track: currentTrack)
            observer.updateTime(currentTime: currentTime, totalDuration: duration)
            observer.updateButtonsStates(isPlaying: player.isPlaying)
            observer.updatePlayOrderButtonState(playOrder: playlist.playOrder)
        }
    }
}

extension QuickPlayerService : LooperClient {
    @objc func loop() {
        let player = AudioPlayer.shared
        let currentTime = player.currentPositionSec
        let duration = player.durationSec
        
        for observer in observers
        {
            observer.value?.updateTime(currentTime: currentTime, totalDuration: duration)
        }
        
        // Audio player state check
        if audioState.isStateOutdated(player: player)
        {
            audioState = QuickPlayerAudioState(player: player)
            
            for observer in observers
            {
                if let value = observer.value
                {
                    fullyUpdateObserver(value)
                }
            }
        }
    }
}

extension QuickPlayerService : AudioPlayerObserver {
    func onPlayerPlay(current: AudioTrack) {
        for observer in observers
        {
            observer.value?.updateMediaInfo(track: current)
        }
    }
    
    func onPlayerFinish() {
        for observer in observers
        {
            observer.value?.updateButtonsStates(isPlaying: false)
        }
    }
    
    func onPlayerStop() {
        for observer in observers
        {
            observer.value?.updateButtonsStates(isPlaying: false)
        }
    }
    
    func onPlayerPause(track: AudioTrack) {
        for observer in observers
        {
            observer.value?.updateButtonsStates(isPlaying: false)
        }
    }
    
    func onPlayerResume(track: AudioTrack) {
        for observer in observers
        {
            observer.value?.updateButtonsStates(isPlaying: true)
        }
    }
}
