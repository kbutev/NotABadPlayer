//
//  AudioPlayer.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation
import AVFoundation

enum AudioPlayerError : Error {
    case InvalidFile
}

class AudioPlayer : NSObject {
    static let shared = AudioPlayer()
    
    var initialized: Bool {
        get {
            return self._audioInfo != nil
        }
    }
    
    private var player: AVAudioPlayer?
    
    var isPlaying: Bool {
        get {
            return self.player?.isPlaying ?? false
        }
    }
    
    var isCompletelyStopped: Bool {
        get {
            return !(self.playlist?.isPlaying ?? false)
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
            return _volume
        }
        
        set {
            if newValue < 0 {
                self._volume = 0
            } else if newValue > 100 {
                self._volume = 100
            } else {
                self._volume = newValue
            }
            
            if !self.muted
            {
                self.player?.volume = Float(self._volume) / 100
            }
        }
    }
    
    private (set) var _audioInfo: AudioInfo?
    
    var audioInfo: AudioInfo {
        get {
            checkIfPlayerIsInitialized()
            
            return _audioInfo!
        }
    }
    
    private var observers: [AudioPlayerObserverValue] = []
    
    var hasPlaylist: Bool {
        get {
            return self.playlist != nil
        }
    }
    
    private (set) var playlist: AudioPlaylist?
    
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
            return self.playlist?.playingTrack
        }
    }
    
    private (set) var playHistory: [AudioTrack] = []
    
    private (set) var muted: Bool = false
    
    override private init() {
        
    }
    
    func initialize(audioInfo: AudioInfo) {
        if initialized {
            fatalError("[\(String(describing: AudioPlayer.self))] must not call initialize() twice")
        }
        
        self._audioInfo = audioInfo
    }
    
    func play(playlist: AudioPlaylist) throws {
        checkIfPlayerIsInitialized()
        
        do {
            try play(track: playlist.playingTrack)
        } catch let error {
            stop()
            throw error
        }
        
        self.playlist = playlist
        self.playlist?.playCurrent()
    }
    
    private func play(track: AudioTrack, usePlayHistory: Bool=true) throws {
        checkIfPlayerIsInitialized()
        
        let url = track.filePath
        
        do {
            try self.player = AVAudioPlayer(contentsOf: url)
            self.player?.delegate = self
            
            Logging.log(AudioPlayer.self, "Playing track '\(track.title)'")
            
            player?.play()
            
            onPlay(track: track)
        } catch let error {
            Logging.log(AudioPlayer.self, "Error: cannot play track, \(error.localizedDescription)")
            stop()
            throw error
        }
        
        if usePlayHistory
        {
            addToPlayHistory(newTrack: track)
        }
    }
    
    func resume() {
        checkIfPlayerIsInitialized()
        
        if !hasPlaylist
        {
            return
        }
        
        guard let playlist = self.playlist else {
            return
        }
        
        if isCompletelyStopped {
            do {
                try play(track: playlist.playingTrack)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not resume, \(error.localizedDescription)")
                return
            }
        }
        
        if !isPlaying
        {
            self.player?.play()
            
            self.onResume(track: playlist.playingTrack)
        }
    }
    
    func pause() {
        checkIfPlayerIsInitialized()
        
        if !hasPlaylist
        {
            return
        }
        
        guard let playlist = self.playlist else {
            return
        }
        
        if isPlaying
        {
            self.player?.pause()
            
            self.onPause(track: playlist.playingTrack)
        }
    }
    
    func stop() {
        checkIfPlayerIsInitialized()
        
        if !hasPlaylist
        {
            return
        }
        
        if currentPositionMSec > 0
        {
            self.player?.stop()
            
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
    
    func playNext() {
        checkIfPlayerIsInitialized()
        
        if !hasPlaylist
        {
            return
        }
        
        self.playlist?.goToNextPlayingTrack()
        
        guard let playlist = self.playlist else {
            return
        }
        
        if !isCompletelyStopped
        {
            let playingTrack = playlist.playingTrack
            
            Logging.log(AudioPlayer.self, "Playing next track...")
            
            do {
                try play(track: playingTrack)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play next, \(error.localizedDescription)")
                stop()
                return
            }
        }
        else
        {
            Logging.log(AudioPlayer.self, "Stop playing, got to last track")
            
            stop()
            
            onStop()
        }
    }
    
    func playPrevious() {
        checkIfPlayerIsInitialized()
        
        if !hasPlaylist
        {
            return
        }
        
        self.playlist?.goToPreviousPlayingTrack()
        
        guard let playlist = self.playlist else {
            return
        }
        
        if !isCompletelyStopped
        {
            let playingTrack = playlist.playingTrack
            
            Logging.log(AudioPlayer.self, "Playing previous track...")
            
            do {
                try play(track: playingTrack)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play previous, \(error.localizedDescription)")
                stop()
                return
            }
        }
        else
        {
            Logging.log(AudioPlayer.self, "Stop playing, got to last track")
            
            stop()
            
            onStop()
        }
    }
    
    func playNextBasedOnPlayOrder() {
        checkIfPlayerIsInitialized()
        
        self.playlist?.goToTrackBasedOnPlayOrder(playOrder: _playOrder)
        
        guard let playlist = self.playlist else {
            return
        }
        
        if !isCompletelyStopped
        {
            let playingTrack = playlist.playingTrack
            
            Logging.log(AudioPlayer.self, "Playing next track based on play order...")
            
            do {
                try play(track: playingTrack)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play next based on play order, \(error.localizedDescription)")
                stop()
                return
            }
        }
        else
        {
            Logging.log(AudioPlayer.self, "Stop playing, got to last track")
            
            stop()
            
            onStop()
        }
    }
    
    func shuffle() {
        checkIfPlayerIsInitialized()
        
        self.playlist?.goToTrackByShuffle()
        
        guard let playlist = self.playlist else {
            return
        }
        
        if !isCompletelyStopped
        {
            Logging.log(AudioPlayer.self, "Playing random track...")
            
            do {
                try play(track: playlist.playingTrack)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play random, \(error.localizedDescription)")
                stop()
                return
            }
        }
        else
        {
            Logging.log(AudioPlayer.self, "Stop playing, got to last track")
            
            stop()
            
            onStop()
        }
    }
    
    func jumpBackwards(_ msec: Int) {
        checkIfPlayerIsInitialized()
        
        guard let p = self.player else {
            return
        }
        
        let seekToPositionInSeconds = TimeInterval(Double(msec * 1000))
        
        if p.currentTime - seekToPositionInSeconds > 0
        {
            p.currentTime = p.currentTime + seekToPositionInSeconds
        }
        else
        {
            p.currentTime = TimeInterval(0)
        }
    }
    
    func jumpForwards(_ msec: Int) {
        checkIfPlayerIsInitialized()
        
        guard let p = player else {
            return
        }
        
        let seekToPositionInSeconds = TimeInterval(Double(msec * 1000))
        
        if p.currentTime + seekToPositionInSeconds < p.duration
        {
            p.currentTime = p.currentTime + seekToPositionInSeconds
        }
        else
        {
            p.currentTime = p.duration
        }
    }
    
    func seekTo(seconds: Double) {
        checkIfPlayerIsInitialized()
        
        self.player?.currentTime = TimeInterval(seconds)
    }
    
    func seekTo(mseconds: Int) {
        checkIfPlayerIsInitialized()
        
        let seekToPositionInSeconds = TimeInterval(Double(mseconds * 1000))
        
        self.player?.currentTime = seekToPositionInSeconds
    }
    
    func volumeUp() {
        checkIfPlayerIsInitialized()
        
        self.volume = self.volume + 10
    }
    
    func volumeDown() {
        checkIfPlayerIsInitialized()
        
        self.volume = self.volume - 10
    }
    
    func mute() {
        checkIfPlayerIsInitialized()
        
        if !self.muted
        {
            Logging.log(AudioPlayer.self, "Mute")
            
            self.muted = true
            
            self.player?.volume = 0
        }
    }
    
    func unmute() {
        checkIfPlayerIsInitialized()
        
        if self.muted
        {
            Logging.log(AudioPlayer.self, "Unmute")
            
            self.muted = false
            
            // Set the player volume to equal @_volume
            self.volume = self._volume
        }
    }
    
    func muteOrUnmute() {
        checkIfPlayerIsInitialized()
        
        if self.muted
        {
            self.unmute()
        }
        else
        {
            self.mute()
        }
    }
    
    private func checkIfPlayerIsInitialized() {
        if !self.initialized
        {
            fatalError("[\(String(describing: AudioPlayer.self))] being used before being initialized, initialize() has never been called")
        }
    }
}

// Component - Observers
extension AudioPlayer {
    func attach(observer: AudioPlayerObserver) {
        if observers.contains(where: {(element) -> Bool in element.value === observer})
        {
            return
        }
        
        observers.append(AudioPlayerObserverValue(observer))
    }
    
    func detach(observer: AudioPlayerObserver) {
        observers.removeAll(where: {(element) -> Bool in element.value === observer})
    }
    
    private func onPlay(track: AudioTrack) {
        for observer in observers
        {
            observer.value?.onPlayerPlay(current: track)
        }
    }
    
    private func onFinish() {
        for observer in observers
        {
            observer.value?.onPlayerFinish()
        }
    }
    
    private func onStop() {
        for observer in observers
        {
            observer.value?.onPlayerStop()
        }
    }
    
    private func onResume(track: AudioTrack) {
        for observer in observers
        {
            observer.value?.onPlayerResume(track: track)
        }
    }
    
    private func onPause(track: AudioTrack) {
        for observer in observers
        {
            observer.value?.onPlayerPause(track: track)
        }
    }
    
    private func onPlayOrderChange(order: AudioPlayOrder) {
        for observer in observers
        {
            observer.value?.onPlayOrderChange(order: order)
        }
    }
}

// Component - Play history
extension AudioPlayer {
    public func setPlayHistory(_ list:[AudioTrack]) {
        playHistory = list
    }
    
    private func addToPlayHistory(newTrack: AudioTrack) {
        // Make sure that the history tracks are unique
        playHistory.removeAll(where: { (element) -> Bool in element == newTrack})
        
        playHistory.insert(newTrack, at: 0)
        
        // Do not exceed the play history capacity
        let capacity = GeneralStorage.shared.getPlayerPlayedHistoryCapacity()
        
        while playHistory.count > capacity
        {
            playHistory.removeLast()
        }
    }
    
    public func playPreviousInPlayHistory() {
        checkIfPlayerIsInitialized()
        
        stop()
        
        if (playHistory.count <= 1)
        {
            return
        }
        
        playHistory.removeFirst()
        
        guard let previousTrack = playHistory.first else {
            return
        }
        
        var newPlaylist = previousTrack.source.getSourcePlaylist(audioInfo: audioInfo, playingTrack: previousTrack)
        
        if newPlaylist == nil
        {
            let playlistName = "Previously played"
            
            newPlaylist = AudioPlaylist(name: playlistName, startWithTrack: previousTrack)
        }
        
        // Play playlist with specific track from play history
        if let resultPlaylist = newPlaylist
        {
            do {
                try play(playlist: resultPlaylist)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play previous in play history, \(error.localizedDescription)")
                stop()
                return
            }
        }
    }
}

extension AudioPlayer : AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.onFinish()
        self.playNextBasedOnPlayOrder()
    }
}
