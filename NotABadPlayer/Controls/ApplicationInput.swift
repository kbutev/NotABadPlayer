//
//  ApplicationInput.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

enum ApplicationInput: String, Codable {
    case HOME_BUTTON;
    case SCREEN_LOCK_BUTTON;
    case EARPHONES_UNPLUG;
    case PLAYER_VOLUME_UP_BUTTON;
    case PLAYER_VOLUME_DOWN_BUTTON;
    case PLAYER_VOLUME;
    case PLAYER_RECALL;
    case PLAYER_PLAY_BUTTON;
    case PLAYER_NEXT_BUTTON;
    case PLAYER_PREVIOUS_BUTTON;
    case PLAYER_SWIPE_LEFT;
    case PLAYER_SWIPE_RIGHT;
    case QUICK_PLAYER_VOLUME_UP_BUTTON;
    case QUICK_PLAYER_VOLUME_DOWN_BUTTON;
    case QUICK_PLAYER_PLAY_BUTTON;
    case QUICK_PLAYER_NEXT_BUTTON;
    case QUICK_PLAYER_PREVIOUS_BUTTON;
    case LOCK_PLAYER_NEXT_BUTTON;
    case LOCK_PLAYER_PREVIOUS_BUTTON;
}
