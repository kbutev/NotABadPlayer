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

protocol QuickPlayerObserver : class {
    func updateTime(currentTime: Double, totalDuration: Double)
    func updateMediaInfo(track: AudioTrack)
    func updatePlayButtonState(isPlaying: Bool)
    func updatePlayOrderButtonState(order: AudioPlayOrder)
}

class QuickPlayerService : NSObject {
    public static let LOOP_INTERVAL_SECONDS: Double = 0.4
    
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
                return elementValue === observer
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
            observer.updatePlayButtonState(isPlaying: player.isPlaying)
            observer.updatePlayOrderButtonState(order: player.playOrder)
        }
        else
        {
            observer.updateTime(currentTime: 0, totalDuration: 0)
            observer.updatePlayButtonState(isPlaying: false)
            observer.updatePlayOrderButtonState(order: player.playOrder)
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
    }
}

extension QuickPlayerService : AudioPlayerObserver {
    func onPlayerPlay(current: AudioTrack) {
        for observer in observers
        {
            observer.value?.updateMediaInfo(track: current)
            observer.value?.updatePlayButtonState(isPlaying: true)
        }
    }
    
    func onPlayerFinish() {
        for observer in observers
        {
            observer.value?.updatePlayButtonState(isPlaying: false)
        }
    }
    
    func onPlayerStop() {
        for observer in observers
        {
            observer.value?.updatePlayButtonState(isPlaying: false)
        }
    }
    
    func onPlayerPause(track: AudioTrack) {
        for observer in observers
        {
            observer.value?.updatePlayButtonState(isPlaying: false)
        }
    }
    
    func onPlayerResume(track: AudioTrack) {
        for observer in observers
        {
            observer.value?.updatePlayButtonState(isPlaying: true)
        }
    }
    
    func onPlayOrderChange(order: AudioPlayOrder) {
        for observer in observers
        {
            observer.value?.updatePlayOrderButtonState(order: order)
        }
    }
    
    func onVolumeChanged(volume: Double) {
        
    }
}
