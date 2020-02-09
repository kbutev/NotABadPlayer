//
//  AudioPlayer.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import AVFoundation

enum AudioPlayerError: Error {
    case invalidArgument(String)
}

// Standart audio player for the app.
// Before using the player, you MUST call start().
// Dependant on @GeneralStorage (must be initialized before using the player).
// Dependant on storage access permission.
class AudioPlayer : NSObject {
    static let shared = AudioPlayer()
    
    private let synchronous: DispatchQueue
    private let playSync: DispatchQueue
    
    var isRunning: Bool {
        get {
            return synchronous.sync {
                return self._audioInfo != nil
            }
        }
    }
    
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private var player: AVAudioPlayer?
    
    var isPlaying: Bool {
        get {
            return self.player?.isPlaying ?? false
        }
    }
    
    var isCompletelyStopped: Bool {
        get {
            if let playlist = self.safeMutablePlaylist {
                return !playlist.isPlaying
            }
            
            return true
        }
    }
    
    var durationSec: Double {
        get {
            if !self.hasPlaylist {
                return 0
            }
            
            return self.player?.duration ?? 0
        }
    }
    
    var durationMSec: Double {
        get {
            return self.durationSec * 1000.0
        }
    }
    
    var currentPositionSec: Double {
        get {
            if !self.hasPlaylist {
                return 0
            }
            
            return self.player?.currentTime ?? 0
        }
    }
    
    var currentPositionMSec: Double {
        get {
            return self.currentPositionSec * 1000.0
        }
    }
    
    private var _volume: Int = 0
    
    var volume: Int {
        get {
            return synchronous.sync {
                return _volume
            }
        }
        
        set {
            var value = newValue
            
            synchronous.sync {
                value = value < 0 ? 0 : value
                value = value > 100 ? 100 : value
                self._volume = value
            }
            
            updateAVPlayerVolume(value)
        }
    }
    
    private (set) var _audioInfo: AudioInfo?
    
    var audioInfo: AudioInfo {
        get {
            checkIfPlayerIsInitialized()
            
            return synchronous.sync {
                return _audioInfo!
            }
        }
    }
    
    private var _observers: [AudioPlayerObserverValue] = []
    
    var hasPlaylist: Bool {
        get {
            return self.safeMutablePlaylist != nil
        }
    }
    
    private var __unsafePlaylist: SafeMutableAudioPlaylist?
    
    private var safeMutablePlaylist: SafeMutableAudioPlaylist? {
        get {
            return synchronous.sync {
                return __unsafePlaylist
            }
        }
        set {
            synchronous.sync {
                __unsafePlaylist = newValue
            }
        }
    }
    
    public var playlist: BaseAudioPlaylist? {
        get {
            return self.safeMutablePlaylist?.copy()
        }
    }
    
    private var _playOrder: AudioPlayOrder = .FORWARDS
    
    public var playOrder: AudioPlayOrder {
        get {
            return _playOrder
        }
        
        set {
            self._playOrder = newValue
            
            onPlayOrderChange(order: _playOrder)
        }
    }
    
    public var playingTrack: AudioTrack? {
        get {
            return self.safeMutablePlaylist?.playingTrack
        }
    }
    
    public var isMuted: Bool {
        get {
            return synchronous.sync {
                return _muted
            }
        }
    }
    
    private (set) var _muted: Bool = false
    
    public var playerHistory: AudioPlayerHistory
    private var remote: AudioPlayerRemote
    
    private init(_ remote: AudioPlayerRemote?=nil) {
        synchronous = DispatchQueue(label: "AudioPlayer.synchronous")
        playSync = DispatchQueue(label: "AudioPlayer.synchronous.play")
        self.playerHistory = AudioPlayerHistory()
        self.remote = AudioPlayerRemote()
        super.init()
        self.playerHistory = AudioPlayerHistory(player: self)
        self.remote = remote ?? AudioPlayerRemote(player: self)
    }
    
    func start(audioInfo: AudioInfo) {
        if self.isRunning
        {
            fatalError("[\(String(describing: AudioPlayer.self))] must not call start() twice")
        }
        
        synchronous.sync {
            self._audioInfo = audioInfo
        }
        
        // Setup audio session
        do {
            try self.audioSession.setCategory(.playback)
            try self.audioSession.setActive(true)
        } catch let e {
            fatalError("[\(String(describing: AudioPlayer.self))] could not start audio session properly: \(e.localizedDescription)")
        }
        
        // Subscribe for general storage events
        GeneralStorage.shared.attach(observer: remote)
    }
    
    public func play(playlist: BaseAudioPlaylist, pauseImmediately: Bool=false) throws {
        checkIfPlayerIsInitialized()
        
        var mutablePlaylist: MutableAudioPlaylist? = nil
        
        do {
            let node = AudioPlaylistBuilder.start(prototype: playlist)
            mutablePlaylist = try node.buildMutable()
        } catch let error {
            throw error
        }
        
        do {
            let newPlaylist = try SafeMutableAudioPlaylist.build(mutablePlaylist!)
            
            try playSync.sync {
                try play(track: playlist.playingTrack, pauseImmediately: pauseImmediately)
                
                self.safeMutablePlaylist = newPlaylist
                
                newPlaylist.playCurrent()
            }
        } catch let error {
            throw error
        }
    }
    
    private func play(track: AudioTrack, previousTrack: AudioTrack?=nil, pauseImmediately: Bool=false) throws {
        checkIfPlayerIsInitialized()
        
        let wasPlaying = self.isPlaying
        
        guard let url = track.filePath else {
            Logging.log(AudioPlayer.self, "Error: cannot play track with nil url path")
            throw AudioPlayerError.invalidArgument("Cannot play track with nil url path")
        }
        
        do {
            try self.player = AVAudioPlayer(contentsOf: url)
            self.player?.prepareToPlay()
            self.player?.delegate = self
            
            Logging.log(AudioPlayer.self, "Playing track '\(track.title)'")
            
            self.player?.play()
            
            if pauseImmediately {
                self.player?.pause()
            }
            
            onPlay(track: track)
        } catch let error {
            Logging.log(AudioPlayer.self, "Error: cannot play track, \(error.localizedDescription)")
            
            // If the file fails to play, restore the previous audio state
            if let prevTrackPath = previousTrack?.filePath
            {
                do {
                    try self.player = AVAudioPlayer(contentsOf: prevTrackPath)
                    self.player?.prepareToPlay()
                    self.player?.delegate = self
                    self.player?.play()
                    
                    if pauseImmediately || !wasPlaying
                    {
                        self.player?.pause()
                    }
                }
                catch {
                    
                }
            }
            else
            {
                stop()
            }
            
            throw error
        }
        
        playerHistory.addToPlayHistory(newTrack: track)
        
        remote.updateRemoteCenterInfo(track: track)
    }
    
    func resume() {
        checkIfPlayerIsInitialized()
        
        guard let playlist = self.safeMutablePlaylist else {
            return
        }
        
        if isCompletelyStopped {
            do {
                try play(track: playlist.playingTrack)
                Logging.log(AudioPlayer.self, "Resume")
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not resume, \(error.localizedDescription)")
                return
            }
        }
        
        if !isPlaying
        {
            self.player?.play()
            
            self.onResume(track: playlist.playingTrack)
            
            remote.updateRemoteCenterInfo(track: playlist.playingTrack)
        }
    }
    
    func pause() {
        checkIfPlayerIsInitialized()
        
        guard let playlist = self.safeMutablePlaylist else {
            return
        }
        
        if isPlaying
        {
            self.player?.pause()
            
            Logging.log(AudioPlayer.self, "Pause")
            
            self.onPause(track: playlist.playingTrack)
            
            remote.updateRemoteCenterInfo(track: playlist.playingTrack)
        }
    }
    
    func stop() {
        checkIfPlayerIsInitialized()
        
        if currentPositionMSec > 0
        {
            self.player?.stop()
            
            Logging.log(AudioPlayer.self, "Stop")
            
            self.onStop()
        }
    }
    
    func pauseOrResume() {
        checkIfPlayerIsInitialized()
        
        if !hasPlaylist
        {
            return
        }
        
        if isPlaying
        {
            pause()
        }
        else
        {
            resume()
        }
    }
    
    func playNext() throws {
        checkIfPlayerIsInitialized()
        
        guard let playlist = self.safeMutablePlaylist else {
            return
        }
        
        let previousTrack = playlist.playingTrack
        
        playlist.goToNextPlayingTrack()
        
        if !isCompletelyStopped
        {
            let playingTrack = playlist.playingTrack
            
            Logging.log(AudioPlayer.self, "Playing next track...")
            
            do {
                try play(track: playingTrack)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play next, \(error.localizedDescription)")
                
                playlist.goToTrack(previousTrack)
                onPause(track: previousTrack)
                
                throw error
            }
        }
        else
        {
            Logging.log(AudioPlayer.self, "Stop playing, got to last track")
            
            stop()
            
            onStop()
        }
    }
    
    func playPrevious() throws {
        checkIfPlayerIsInitialized()
        
        guard let playlist = self.safeMutablePlaylist else {
            return
        }
        
        let previousTrack = playlist.playingTrack
        
        playlist.goToPreviousPlayingTrack()
        
        if !isCompletelyStopped
        {
            let playingTrack = playlist.playingTrack
            
            Logging.log(AudioPlayer.self, "Playing previous track...")
            
            do {
                try play(track: playingTrack)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play previous, \(error.localizedDescription)")
                
                playlist.goToTrack(previousTrack)
                onPause(track: previousTrack)
                
                throw error
            }
        }
        else
        {
            Logging.log(AudioPlayer.self, "Stop playing, got to first track")
            
            stop()
            
            onStop()
        }
    }
    
    func playNextBasedOnPlayOrder() throws {
        checkIfPlayerIsInitialized()
        
        guard let playlist = self.safeMutablePlaylist else {
            return
        }
        
        let previousTrack = playlist.playingTrack
        
        playlist.goToTrackBasedOnPlayOrder(playOrder: _playOrder)
        
        if !isCompletelyStopped
        {
            let playingTrack = playlist.playingTrack
            
            Logging.log(AudioPlayer.self, "Playing next track based on play order...")
            
            do {
                try play(track: playingTrack)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play next based on play order, \(error.localizedDescription)")
                
                playlist.goToTrack(previousTrack)
                onPause(track: previousTrack)
                
                throw error
            }
        }
        else
        {
            Logging.log(AudioPlayer.self, "Stop playing, got to last track")
            
            stop()
            
            onStop()
        }
    }
    
    func shuffle() throws {
        checkIfPlayerIsInitialized()
        
        guard let playlist = self.safeMutablePlaylist else {
            return
        }
        
        let previousTrack = playlist.playingTrack
        
        playlist.goToTrackByShuffle()
        
        if !isCompletelyStopped
        {
            Logging.log(AudioPlayer.self, "Playing random track...")
            
            do {
                try play(track: playlist.playingTrack)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play random, \(error.localizedDescription)")
                
                playlist.goToTrack(previousTrack)
                onPause(track: previousTrack)
                
                throw error
            }
        }
        else
        {
            Logging.log(AudioPlayer.self, "Stop playing, got to last track")
            
            stop()
            
            onStop()
        }
    }
    
    func playPreviousInPlayHistory() {
        checkIfPlayerIsInitialized()
        
        playerHistory.playPreviousInPlayHistory()
    }
    
    func jumpBackwards(seconds: Double) {
        checkIfPlayerIsInitialized()
        
        guard let p = self.player else {
            return
        }
        
        let sec = TimeInterval(seconds)
        
        if p.currentTime - sec > 0
        {
            p.currentTime = p.currentTime - sec
        }
        else
        {
            p.currentTime = TimeInterval(0)
        }
        
        if let playlist = self.safeMutablePlaylist
        {
            remote.updateRemoteCenterInfo(track: playlist.playingTrack)
        }
    }
    
    func jumpForwards(seconds: Double) {
        checkIfPlayerIsInitialized()
        
        guard let p = player else {
            return
        }
        
        let sec = TimeInterval(seconds)
        
        if p.currentTime + sec < p.duration
        {
            p.currentTime = p.currentTime + sec
        }
        else
        {
            p.currentTime = p.duration
        }
        
        if let playlist = self.safeMutablePlaylist
        {
            remote.updateRemoteCenterInfo(track: playlist.playingTrack)
        }
    }
    
    func seekTo(seconds: Double) {
        checkIfPlayerIsInitialized()
        
        self.player?.currentTime = TimeInterval(seconds)
        
        if let playlist = self.safeMutablePlaylist
        {
            remote.updateRemoteCenterInfo(track: playlist.playingTrack)
        }
    }
    
    func seekTo(mseconds: Int) {
        checkIfPlayerIsInitialized()
        
        let seekToPositionInSeconds = TimeInterval(Double(mseconds * 1000))
        
        self.player?.currentTime = seekToPositionInSeconds
        
        if let playlist = self.safeMutablePlaylist
        {
            remote.updateRemoteCenterInfo(track: playlist.playingTrack)
        }
    }
    
    func volumeUp() {
        checkIfPlayerIsInitialized()
        
        self.volume = self.volume + 10
    }
    
    func volumeDown() {
        checkIfPlayerIsInitialized()
        
        self.volume = self.volume - 10
    }
    
    private func updateAVPlayerVolume(_ volume: Int) {
        var value = Float(volume) / 100
        
        if self.isMuted {
            value = 0
        }
        
        synchronous.sync {
            self.player?.volume = value
        }
    }
    
    func mute() {
        checkIfPlayerIsInitialized()
        
        if !self.isMuted
        {
            Logging.log(AudioPlayer.self, "Mute")
            
            synchronous.sync {
                self._muted = true
            }
            
            updateAVPlayerVolume(0)
        }
    }
    
    func unmute() {
        checkIfPlayerIsInitialized()
        
        if self.isMuted
        {
            Logging.log(AudioPlayer.self, "Unmute")
            
            synchronous.sync {
                self._muted = false
            }
            
            updateAVPlayerVolume(self.volume)
        }
    }
    
    func muteOrUnmute() {
        checkIfPlayerIsInitialized()
        
        if self.isMuted
        {
            self.unmute()
        }
        else
        {
            self.mute()
        }
    }
    
    private func checkIfPlayerIsInitialized() {
        if !self.isRunning
        {
            fatalError("[\(String(describing: AudioPlayer.self))] being used before being initialized, initialize() has never been called")
        }
    }
}

// Component - Observers
extension AudioPlayer {
    func attach(observer: AudioPlayerObserver) {
        synchronous.sync {
            if _observers.contains(where: {(element) -> Bool in element.value === observer})
            {
                return
            }
            
            _observers.append(AudioPlayerObserverValue(observer))
        }
    }
    
    func detach(observer: AudioPlayerObserver) {
        synchronous.sync {
            _observers.removeAll(where: {(element) -> Bool in element.value === observer})
        }
    }
    
    private func onPlay(track: AudioTrack) {
        let observers = synchronous.sync {
            return _observers
        }
        
        for observer in observers
        {
            observer.value?.onPlayerPlay(current: track)
        }
    }
    
    private func onFinish() {
        let observers = synchronous.sync {
            return _observers
        }
        
        for observer in observers
        {
            observer.value?.onPlayerFinish()
        }
    }
    
    private func onStop() {
        let observers = synchronous.sync {
            return _observers
        }
        
        for observer in observers
        {
            observer.value?.onPlayerStop()
        }
    }
    
    private func onResume(track: AudioTrack) {
        let observers = synchronous.sync {
            return _observers
        }
        
        for observer in observers
        {
            observer.value?.onPlayerResume(track: track)
        }
    }
    
    private func onPause(track: AudioTrack) {
        let observers = synchronous.sync {
            return _observers
        }
        
        for observer in observers
        {
            observer.value?.onPlayerPause(track: track)
        }
    }
    
    private func onPlayOrderChange(order: AudioPlayOrder) {
        let observers = synchronous.sync {
            return _observers
        }
        
        for observer in observers
        {
            observer.value?.onPlayOrderChange(order: order)
        }
    }
    
    private func onVolumeChanged(volume: Double) {
        let observers = synchronous.sync {
            return _observers
        }
        
        for observer in observers
        {
            observer.value?.onVolumeChanged(volume: volume)
        }
    }
}

// AVAudioPlayerDelegate
extension AudioPlayer : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.onFinish()
        
        do {
            try self.playNextBasedOnPlayOrder()
        } catch {
            
        }
    }
    
    func audioPlayerBeginInterruption(_ player: AVAudioPlayer) {
        self.onStop()
    }
}
