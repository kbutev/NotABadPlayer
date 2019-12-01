//
//  AudioPlayer.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 12.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import UIKit
import MediaPlayer
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
    
    var running: Bool {
        get {
            return self._audioInfo != nil
        }
    }
    
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    private let remoteControl: MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
    private let remoteControlInfo: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    private var player: AVAudioPlayer?
    
    var isPlaying: Bool {
        get {
            return self.player?.isPlaying ?? false
        }
    }
    
    var isCompletelyStopped: Bool {
        get {
            return !(self._playlist?.isPlaying ?? false)
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
            return self._playlist != nil
        }
    }
    
    private var _playlist: MutableAudioPlaylist?
    
    public var playlist: BaseAudioPlaylist? {
        get {
            return _playlist
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
            return self._playlist?.playingTrack
        }
    }
    
    private (set) var playHistory: [AudioTrack] = []
    
    private (set) var muted: Bool = false
    
    override private init() {
        
    }
    
    func start(audioInfo: AudioInfo) {
        if running
        {
            fatalError("[\(String(describing: AudioPlayer.self))] must not call start() twice")
        }
        
        self._audioInfo = audioInfo
        
        // Setup audio session
        do {
            try self.audioSession.setCategory(.playback)
            try self.audioSession.setActive(true)
        } catch let e {
            fatalError("[\(String(describing: AudioPlayer.self))] could not start audio session properly: \(e.localizedDescription)")
        }
        
        // Setup remote control - user can control the audio from the lock screen
        setupRemoteControl()
        
        // Subscribe for general storage events
        GeneralStorage.shared.attach(observer: self)
    }
    
    private func setupRemoteControl() {
        remoteControl.togglePlayPauseCommand.isEnabled = true
        remoteControl.togglePlayPauseCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            if self.hasPlaylist
            {
                self.pauseOrResume()
                return .success
            }
            
            return .commandFailed
        })
        
        remoteControl.changePlaybackPositionCommand.isEnabled = true
        remoteControl.changePlaybackPositionCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else
            {
                return .commandFailed
            }
            
            if self.hasPlaylist
            {
                let time = event.positionTime as Double
                
                self.seekTo(seconds: time)
                
                return .success
            }
            
            return .commandFailed
        })
        
        remoteControl.skipBackwardCommand.isEnabled = false
        remoteControl.skipBackwardCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            return self._remoteActionBackwards(event: event)
        })
        
        remoteControl.skipForwardCommand.isEnabled = false
        remoteControl.skipForwardCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            return self._remoteActionForwards(event: event)
        })
        
        remoteControl.previousTrackCommand.isEnabled = false
        remoteControl.previousTrackCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            return self._remoteActionPrevious(event: event)
        })
        
        remoteControl.nextTrackCommand.isEnabled = false
        remoteControl.nextTrackCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            return self._remoteActionNext(event: event)
        })
        
        setupRemoteSkipCommands()
    }
    
    public func play(playlist: BaseAudioPlaylist) throws {
        checkIfPlayerIsInitialized()
        
        var mutablePlaylist: MutableAudioPlaylist? = nil
        
        do {
            let node = AudioPlaylistBuilder.start(prototype: playlist)
            mutablePlaylist = try node.buildMutable()
        } catch let error {
            throw error
        }
        
        do {
            try play(track: playlist.playingTrack)
        } catch let error {
            throw error
        }
        
        self._playlist = mutablePlaylist!
        self._playlist?.playCurrent()
    }
    
    private func play(track: AudioTrack, previousTrack: AudioTrack?=nil, usePlayHistory: Bool=true) throws {
        checkIfPlayerIsInitialized()
        
        let wasPlaying = isPlaying
        
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
                    
                    if !wasPlaying
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
        
        if usePlayHistory
        {
            addToPlayHistory(newTrack: track)
        }
        
        updateRemoteCenterInfo(track: track)
    }
    
    func resume() {
        checkIfPlayerIsInitialized()
        
        if !hasPlaylist
        {
            return
        }
        
        guard let playlist = self._playlist else {
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
            
            updateRemoteCenterInfo(track: playlist.playingTrack)
        }
    }
    
    func pause() {
        checkIfPlayerIsInitialized()
        
        if !hasPlaylist
        {
            return
        }
        
        guard let playlist = self._playlist else {
            return
        }
        
        if isPlaying
        {
            self.player?.pause()
            
            Logging.log(AudioPlayer.self, "Pause")
            
            self.onPause(track: playlist.playingTrack)
            
            updateRemoteCenterInfo(track: playlist.playingTrack)
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
        
        if !hasPlaylist
        {
            return
        }
        
        let previousTrack = self._playlist?.playingTrack
        
        self._playlist?.goToNextPlayingTrack()
        
        guard let playlist = self._playlist else {
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
                
                if let prevTrack = previousTrack
                {
                    self._playlist?.goToTrack(prevTrack)
                    onPause(track: prevTrack)
                }
                
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
        
        if !hasPlaylist
        {
            return
        }
        
        let previousTrack = self._playlist?.playingTrack
        
        self._playlist?.goToPreviousPlayingTrack()
        
        guard let playlist = self._playlist else {
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
                
                if let prevTrack = previousTrack
                {
                    self._playlist?.goToTrack(prevTrack)
                    onPause(track: prevTrack)
                }
                
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
        
        let previousTrack = self._playlist?.playingTrack
        
        self._playlist?.goToTrackBasedOnPlayOrder(playOrder: _playOrder)
        
        guard let playlist = self._playlist else {
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
                
                if let prevTrack = previousTrack
                {
                    self._playlist?.goToTrack(prevTrack)
                    onPause(track: prevTrack)
                }
                
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
        
        let previousTrack = self._playlist?.playingTrack
        
        self._playlist?.goToTrackByShuffle()
        
        guard let playlist = self._playlist else {
            return
        }
        
        if !isCompletelyStopped
        {
            Logging.log(AudioPlayer.self, "Playing random track...")
            
            do {
                try play(track: playlist.playingTrack)
            } catch let error {
                Logging.log(AudioPlayer.self, "Error: could not play random, \(error.localizedDescription)")
                
                if let prevTrack = previousTrack
                {
                    self._playlist?.goToTrack(prevTrack)
                    onPause(track: prevTrack)
                }
                
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
        
        if let playlist = self._playlist
        {
            updateRemoteCenterInfo(track: playlist.playingTrack)
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
        
        if let playlist = self._playlist
        {
            updateRemoteCenterInfo(track: playlist.playingTrack)
        }
    }
    
    func seekTo(seconds: Double) {
        checkIfPlayerIsInitialized()
        
        self.player?.currentTime = TimeInterval(seconds)
        
        if let playlist = self._playlist
        {
            updateRemoteCenterInfo(track: playlist.playingTrack)
        }
    }
    
    func seekTo(mseconds: Int) {
        checkIfPlayerIsInitialized()
        
        let seekToPositionInSeconds = TimeInterval(Double(mseconds * 1000))
        
        self.player?.currentTime = seekToPositionInSeconds
        
        if let playlist = self._playlist
        {
            updateRemoteCenterInfo(track: playlist.playingTrack)
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
        if !self.running
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
    
    private func onVolumeChanged(volume: Double) {
        for observer in observers
        {
            observer.value?.onVolumeChanged(volume: volume)
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
            let playlistName = Text.value(.PlaylistRecentlyPlayed)
            
            var node = AudioPlaylistBuilder.start()
            node.name = playlistName
            node.startWithTrack = previousTrack
            
            do {
                newPlaylist = try node.build()
            } catch {
                Logging.log(AudioPlayer.self, "Error: failed to build playlist from previous track")
                newPlaylist = nil
            }
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

// Remote control component and general storage extension
extension AudioPlayer: GeneralStorageObserver {
    func onAppAppearanceChange() {
        
    }
    
    func onTabCachingPolicyChange(_ value: TabsCachingPolicy) {
        
    }
    
    func onKeybindChange(forInput: ApplicationInput) {
        reloadRemoteControls()
    }
    
    func onResetDefaultSettings() {
        
    }
    
    private func reloadRemoteControls() {
        setupRemoteSkipCommands()
    }
    
    private func updateRemoteCenterInfo(track: AudioTrack) {
        var nowPlaying: [String : Any] = [:]
        
        nowPlaying[MPMediaItemPropertyAlbumTitle] = track.albumTitle
        nowPlaying[MPMediaItemPropertyTitle] = track.title
        
        if let artwork = track.albumCover
        {
            nowPlaying[MPMediaItemPropertyArtwork] = artwork
        }
        
        nowPlaying[MPMediaItemPropertyPlaybackDuration] = Float(track.durationInSeconds)
        nowPlaying[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float(currentPositionSec)
        
        remoteControlInfo.nowPlayingInfo = nowPlaying
    }
    
    private func setupRemoteSkipCommands() {
        remoteControl.previousTrackCommand.isEnabled = false
        remoteControl.nextTrackCommand.isEnabled = false
        remoteControl.skipBackwardCommand.isEnabled = false
        remoteControl.skipForwardCommand.isEnabled = false
        
        setupCommand(previous: true)
        setupCommand(previous: false)
    }
    
    private func setupCommand(previous: Bool) {
        let input = previous ? ApplicationInput.LOCK_PLAYER_PREVIOUS_BUTTON : ApplicationInput.LOCK_PLAYER_NEXT_BUTTON
        let action = GeneralStorage.shared.getKeybindAction(forInput: input)
        
        switch action {
        case .PREVIOUS:
            remoteControl.previousTrackCommand.isEnabled = true
            break
        case .NEXT:
            remoteControl.nextTrackCommand.isEnabled = true
            break
        case .BACKWARDS_8:
            remoteControl.skipBackwardCommand.isEnabled = true
            remoteControl.skipBackwardCommand.preferredIntervals = [NSNumber(8)]
            break
        case .BACKWARDS_15:
            remoteControl.skipBackwardCommand.isEnabled = true
            remoteControl.skipBackwardCommand.preferredIntervals = [NSNumber(15)]
            break
        case .BACKWARDS_30:
            remoteControl.skipBackwardCommand.isEnabled = true
            remoteControl.skipBackwardCommand.preferredIntervals = [NSNumber(30)]
            break
        case .BACKWARDS_60:
            remoteControl.skipBackwardCommand.isEnabled = true
            remoteControl.skipBackwardCommand.preferredIntervals = [NSNumber(60)]
            break
        case .FORWARDS_8:
            remoteControl.skipForwardCommand.isEnabled = true
            remoteControl.skipForwardCommand.preferredIntervals = [NSNumber(8)]
            break
        case .FORWARDS_15:
            remoteControl.skipForwardCommand.isEnabled = true
            remoteControl.skipForwardCommand.preferredIntervals = [NSNumber(15)]
            break
        case .FORWARDS_30:
            remoteControl.skipForwardCommand.isEnabled = true
            remoteControl.skipForwardCommand.preferredIntervals = [NSNumber(30)]
            break
        case .FORWARDS_60:
            remoteControl.skipForwardCommand.isEnabled = true
            remoteControl.skipForwardCommand.preferredIntervals = [NSNumber(60)]
            break
        default:
            break
        }
    }
    
    @objc func _remoteActionPrevious(event:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if self._playlist != nil
        {
            do {
                try playPrevious()
            } catch {
                
            }
            return .success
        }
        
        return .commandFailed
    }
    
    @objc func _remoteActionNext(event:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if self._playlist != nil
        {
            do {
                try playNext()
            } catch {
                
            }
            return .success
        }
        
        return .commandFailed
    }
    
    @objc func _remoteActionBackwards(event:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let playlist = self._playlist
        {
            let _ = Keybinds.shared.evaluateInput(input: .LOCK_PLAYER_PREVIOUS_BUTTON)
            updateRemoteCenterInfo(track: playlist.playingTrack)
            return .success
        }
        
        return .commandFailed
    }
    
    @objc func _remoteActionForwards(event:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        if let playlist = self._playlist
        {
            let _ = Keybinds.shared.evaluateInput(input: .LOCK_PLAYER_NEXT_BUTTON)
            updateRemoteCenterInfo(track: playlist.playingTrack)
            return .success
        }
        
        return .commandFailed
    }
}

// Serialization
extension AudioPlayer {
    func serializePlaylist() -> String? {
        guard let playlist = self._playlist else {
            return nil
        }
        
        do {
            var node = AudioPlaylistBuilder.start(prototype: playlist)
            node.isTemporary = true
            return Serializing.serialize(object: try node.buildMutable())
        } catch {
            
        }
        
        return nil
    }
}
