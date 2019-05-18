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

protocol AudioPlayerObserver : class {
    func onPlayerPlay(current: AudioTrack)
    func onPlayerFinish()
    func onPlayerStop()
    func onPlayerPause(track: AudioTrack)
    func onPlayerResume(track: AudioTrack)
}
