//
//  AudioPlayerObserver.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

struct AudioPlayerObserverValue
{
    weak var observer : AudioPlayerObserver?
    
    init(_ observer: AudioPlayerObserver)
    {
        self.observer = observer
    }
    
    var value : AudioPlayerObserver? {
        get {
            return observer
        }
    }
}

// Note: Delegation may be performed on a background thread.
protocol AudioPlayerObserver : class {
    func onPlayerPlay(current: AudioTrackProtocol)
    func onPlayerFinish()
    func onPlayerStop()
    func onPlayerPause(track: AudioTrackProtocol)
    func onPlayerResume(track: AudioTrackProtocol)
    func onPlayOrderChange(order: AudioPlayOrder)
    func onVolumeChanged(volume: Double)
}
