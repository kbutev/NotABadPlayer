//
//  AudioPlayer.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import AVFoundation

class AudioPlayerService {
    private static let _singleton = StandardAudioPlayer()
    
    static let shared: AudioPlayer = AudioPlayerService._singleton
    static let observing: AudioPlayerObserving = AudioPlayerService._singleton
}

enum AudioPlayerError: Error {
    case invalidArgument(String)
}

protocol AudioPlayer: AnyObject {
    var isRunning: Bool { get }
    var isPlaying: Bool { get }
    var isCompletelyStopped: Bool { get }
    var durationSec: Double { get }
    var durationMSec: Double { get }
    var currentPositionSec: Double { get }
    var currentPositionMSec: Double { get }
    var volume: Int { get set }
    var audioInfo: AudioInfo { get }
    var hasPlaylist: Bool { get }
    var playlist: BaseAudioPlaylist? { get }
    var playOrder: AudioPlayOrder { get set }
    var playingTrack: BaseAudioTrack? { get }
    var isMuted: Bool { get }
    var playerHistory: AudioPlayerHistory { get }
    
    func start(audioInfo: AudioInfo)
    func play(playlist: BaseAudioPlaylist) throws
    func playAndPauseImmediately(playlist: BaseAudioPlaylist) throws
    
    func resume()
    func pause()
    func stop()
    func pauseOrResume()
    
    func playNext() throws
    func playPrevious() throws
    func playNextBasedOnPlayOrder() throws
    func shuffle() throws
    func playPreviousInPlayHistory()
    
    func jumpBackwards(seconds: Double)
    func jumpForwards(seconds: Double)
    func seekTo(seconds: Double)
    func seekTo(mseconds: Int)
    
    func volumeUp()
    func volumeDown()
    
    func mute()
    func unmute()
    func muteOrUnmute()
}

protocol AudioPlayerObserving: AnyObject {
    func attach(observer: AudioPlayerObserver)
    func detach(observer: AudioPlayerObserver)
}
