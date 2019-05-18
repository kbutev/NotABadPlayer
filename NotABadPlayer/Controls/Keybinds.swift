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
        return GeneralStorage.shared.getSettingsAction(forInput: input)
    }
    
    func evaluateInput(input: ApplicationInput) -> ApplicationAction {
        return performAction(action: getActionFor(input: input))
    }
    
    func performAction(action: ApplicationAction) -> ApplicationAction {
        switch action
        {
        case .DO_NOTHING:
            break
        case .EXIT:
            exit(0);
            break
        case .PLAY:
            AudioPlayer.shared.resume();
            break
        case .PAUSE:
            AudioPlayer.shared.pause();
            break
        case .PAUSE_OR_RESUME:
            AudioPlayer.shared.pauseOrResume();
            break
        case .NEXT:
            AudioPlayer.shared.playNext();
            break
        case .PREVIOUS:
            AudioPlayer.shared.playPrevious();
            break
        case .SHUFFLE:
            AudioPlayer.shared.shuffle();
            break
        case .VOLUME_UP:
            AudioPlayer.shared.volumeUp();
            break
        case .VOLUME_DOWN:
            AudioPlayer.shared.volumeDown();
            break
        case .MUTE_OR_UNMUTE:
            AudioPlayer.shared.muteOrUnmute();
            break
        case .FORWARDS_5:
            AudioPlayer.shared.jumpForwards(5);
            break
        case .FORWARDS_8:
            AudioPlayer.shared.jumpForwards(8);
            break
        case .FORWARDS_10:
            AudioPlayer.shared.jumpForwards(10);
            break
        case .FORWARDS_15:
            AudioPlayer.shared.jumpForwards(15);
            break
        case .BACKWARDS_5:
            AudioPlayer.shared.jumpBackwards(5);
            break
        case .BACKWARDS_8:
            AudioPlayer.shared.jumpBackwards(8);
            break
        case .BACKWARDS_10:
            AudioPlayer.shared.jumpBackwards(10);
            break
        case .BACKWARDS_15:
            AudioPlayer.shared.jumpBackwards(15);
            break
        case .CHANGE_PLAY_ORDER:
            if let playlist = AudioPlayer.shared.playlist
            {
                let order = playlist.playOrder
                
                switch order
                {
                case .FORWARDS:
                    playlist.playOrder = .FORWARDS_REPEAT
                    break
                case .FORWARDS_REPEAT:
                    playlist.playOrder = .ONCE_FOREVER
                    break
                case .ONCE_FOREVER:
                    playlist.playOrder = .SHUFFLE
                    break
                case .SHUFFLE:
                    playlist.playOrder = .FORWARDS
                    break
                default:
                    playlist.playOrder = .FORWARDS
                    break
                }
            }
            
            break
        case .RECALL:
            let toDo = 5 // Implement functionality
            break
        }
        
        return action
    }
}
