//
//  Keybinds.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class Keybinds {
    public static let shared = Keybinds()
    
    private init() {
        
    }
    
    func getActionFor(input: ApplicationInput) -> ApplicationAction {
        return GeneralStorage.shared.getKeybindAction(forInput: input)
    }
    
    func evaluateInput(input: ApplicationInput) -> Error? {
        return performAction(action: getActionFor(input: input))
    }
    
    func performAction(action: ApplicationAction) -> Error? {
        switch action
        {
        case .DO_NOTHING:
            break
        case .EXIT:
            exit(0);
            break
        case .PLAY:
            AudioPlayer.shared.resume()
            break
        case .PAUSE:
            AudioPlayer.shared.pause()
            break
        case .PAUSE_OR_RESUME:
            AudioPlayer.shared.pauseOrResume()
            break
        case .NEXT:
            do {
                try AudioPlayer.shared.playNext()
            }
            catch let e
            {
                return e
            }
            break
        case .PREVIOUS:
            do {
                try AudioPlayer.shared.playPrevious()
            }
            catch let e
            {
                return e
            }
            break
        case .SHUFFLE:
            do {
                try AudioPlayer.shared.shuffle()
            }
            catch let e
            {
                return e
            }
            break
        case .MUTE_OR_UNMUTE:
            AudioPlayer.shared.muteOrUnmute()
            break
        case .MUTE:
            AudioPlayer.shared.mute()
            break
        case .FORWARDS_8:
            AudioPlayer.shared.jumpForwards(seconds: 8)
            break
        case .FORWARDS_15:
            AudioPlayer.shared.jumpForwards(seconds: 15)
            break
        case .FORWARDS_30:
            AudioPlayer.shared.jumpForwards(seconds: 30)
            break
        case .FORWARDS_60:
            AudioPlayer.shared.jumpForwards(seconds: 60)
            break
        case .BACKWARDS_8:
            AudioPlayer.shared.jumpBackwards(seconds: 8)
            break
        case .BACKWARDS_15:
            AudioPlayer.shared.jumpBackwards(seconds: 15)
            break
        case .BACKWARDS_30:
            AudioPlayer.shared.jumpBackwards(seconds: 30)
            break
        case .BACKWARDS_60:
            AudioPlayer.shared.jumpBackwards(seconds: 60)
            break
        case .CHANGE_PLAY_ORDER:
            let player = AudioPlayer.shared
            
            let order = player.playOrder
            
            switch order
            {
            case .FORWARDS:
                player.playOrder = .FORWARDS_REPEAT
                break
            case .FORWARDS_REPEAT:
                player.playOrder = .ONCE_FOREVER
                break
            case .ONCE_FOREVER:
                player.playOrder = .SHUFFLE
                break
            case .SHUFFLE:
                player.playOrder = .FORWARDS
                break
            default:
                player.playOrder = .FORWARDS
                break
            }
            
            break
        case .RECALL:
            AudioPlayer.shared.playPreviousInPlayHistory()
            break
        }
        
        return nil
    }
}
