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
            exit(0)
            break
        case .PLAY:
            AudioPlayerService.shared.resume()
            break
        case .PAUSE:
            AudioPlayerService.shared.pause()
            break
        case .PAUSE_OR_RESUME:
            AudioPlayerService.shared.pauseOrResume()
            break
        case .NEXT:
            do {
                try AudioPlayerService.shared.playNext()
            }
            catch let e
            {
                return e
            }
            break
        case .PREVIOUS:
            do {
                try AudioPlayerService.shared.playPrevious()
            }
            catch let e
            {
                return e
            }
            break
        case .SHUFFLE:
            do {
                try AudioPlayerService.shared.shuffle()
            }
            catch let e
            {
                return e
            }
            break
        case .MUTE_OR_UNMUTE:
            AudioPlayerService.shared.muteOrUnmute()
            break
        case .MUTE:
            AudioPlayerService.shared.mute()
            break
        case .FORWARDS_8:
            AudioPlayerService.shared.jumpForwards(seconds: 8)
            break
        case .FORWARDS_15:
            AudioPlayerService.shared.jumpForwards(seconds: 15)
            break
        case .FORWARDS_30:
            AudioPlayerService.shared.jumpForwards(seconds: 30)
            break
        case .FORWARDS_60:
            AudioPlayerService.shared.jumpForwards(seconds: 60)
            break
        case .BACKWARDS_8:
            AudioPlayerService.shared.jumpBackwards(seconds: 8)
            break
        case .BACKWARDS_15:
            AudioPlayerService.shared.jumpBackwards(seconds: 15)
            break
        case .BACKWARDS_30:
            AudioPlayerService.shared.jumpBackwards(seconds: 30)
            break
        case .BACKWARDS_60:
            AudioPlayerService.shared.jumpBackwards(seconds: 60)
            break
        case .CHANGE_PLAY_ORDER:
            let player = AudioPlayerService.shared
            
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
            AudioPlayerService.shared.playPreviousInPlayHistory()
            break
        }
        
        return nil
    }
}
