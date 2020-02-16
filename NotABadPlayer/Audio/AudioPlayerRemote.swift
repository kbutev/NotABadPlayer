//
//  AudioPlayerRemote.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 7.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import Foundation
import MediaPlayer

// Remote control component and general storage extension
class AudioPlayerRemote: GeneralStorageObserver {
    private weak var player: AudioPlayer?
    
    private let remoteControl: MPRemoteCommandCenter = MPRemoteCommandCenter.shared()
    private let remoteControlInfo: MPNowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    
    init() {
        self.player = nil
    }
    
    init(player: AudioPlayer) {
        self.player = player
        
        setupRemoteControl()
    }
    
    public func updateRemoteCenterInfo(track: BaseAudioTrack) {
        var nowPlaying: [String : Any] = [:]
        
        nowPlaying[MPMediaItemPropertyAlbumTitle] = track.albumTitle
        nowPlaying[MPMediaItemPropertyTitle] = track.title
        
        if let artwork = track.albumCover
        {
            nowPlaying[MPMediaItemPropertyArtwork] = artwork
        }
        
        nowPlaying[MPMediaItemPropertyPlaybackDuration] = Float(track.durationInSeconds)
        nowPlaying[MPNowPlayingInfoPropertyElapsedPlaybackTime] = Float(player?.currentPositionSec ?? 0)
        
        remoteControlInfo.nowPlayingInfo = nowPlaying
    }
    
    private func setupRemoteControl() {
        weak var weakSelf = self
        
        remoteControl.togglePlayPauseCommand.isEnabled = true
        remoteControl.togglePlayPauseCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            guard let strongPlayer = weakSelf?.player else
            {
                return .commandFailed
            }
            
            if strongPlayer.hasPlaylist
            {
                strongPlayer.pauseOrResume()
                return .success
            }
            
            return .commandFailed
        })
        
        remoteControl.changePlaybackPositionCommand.isEnabled = true
        remoteControl.changePlaybackPositionCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            guard let strongPlayer = weakSelf?.player else
            {
                return .commandFailed
            }
            
            guard let event = event as? MPChangePlaybackPositionCommandEvent else
            {
                return .commandFailed
            }
            
            if strongPlayer.hasPlaylist
            {
                let time = event.positionTime as Double
                
                strongPlayer.seekTo(seconds: time)
                
                return .success
            }
            
            return .commandFailed
        })
        
        remoteControl.skipBackwardCommand.isEnabled = false
        remoteControl.skipBackwardCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            return weakSelf?._remoteActionBackwards(event: event) ?? .commandFailed
        })
        
        remoteControl.skipForwardCommand.isEnabled = false
        remoteControl.skipForwardCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            return weakSelf?._remoteActionForwards(event: event) ?? .commandFailed
        })
        
        remoteControl.previousTrackCommand.isEnabled = false
        remoteControl.previousTrackCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            return weakSelf?._remoteActionPrevious(event: event) ?? .commandFailed
        })
        
        remoteControl.nextTrackCommand.isEnabled = false
        remoteControl.nextTrackCommand.addTarget(handler: {event -> MPRemoteCommandHandlerStatus in
            return weakSelf?._remoteActionNext(event: event) ?? .commandFailed
        })
        
        setupRemoteSkipCommands()
    }
    
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
        guard let player = self.player else
        {
            return .commandFailed
        }
        
        if player.playlist != nil
        {
            do {
                try player.playPrevious()
            } catch {
                
            }
            return .success
        }
        
        return .commandFailed
    }
    
    @objc func _remoteActionNext(event:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else
        {
            return .commandFailed
        }
        
        if player.playlist != nil
        {
            do {
                try player.playNext()
            } catch {
                
            }
            return .success
        }
        
        return .commandFailed
    }
    
    @objc func _remoteActionBackwards(event:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else
        {
            return .commandFailed
        }
        
        if let playlist = player.playlist
        {
            let _ = Keybinds.shared.evaluateInput(input: .LOCK_PLAYER_PREVIOUS_BUTTON)
            updateRemoteCenterInfo(track: playlist.playingTrack)
            return .success
        }
        
        return .commandFailed
    }
    
    @objc func _remoteActionForwards(event:MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard let player = self.player else
        {
            return .commandFailed
        }
        
        if let playlist = player.playlist
        {
            let _ = Keybinds.shared.evaluateInput(input: .LOCK_PLAYER_NEXT_BUTTON)
            updateRemoteCenterInfo(track: playlist.playingTrack)
            return .success
        }
        
        return .commandFailed
    }
}
