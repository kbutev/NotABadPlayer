//
//  ApplicationAction.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

enum ApplicationAction: String, CaseIterable, Codable {
    case DO_NOTHING;
    case EXIT;
    case PLAY;
    case PAUSE;
    case PAUSE_OR_RESUME;
    case NEXT;
    case PREVIOUS;
    case SHUFFLE;
    case VOLUME_UP;
    case VOLUME_DOWN;
    case MUTE_OR_UNMUTE;
    case FORWARDS_5;
    case FORWARDS_8;
    case FORWARDS_10;
    case FORWARDS_15;
    case BACKWARDS_5;
    case BACKWARDS_8;
    case BACKWARDS_10;
    case BACKWARDS_15;
    case CHANGE_PLAY_ORDER;
    case RECALL;
    
    static func stringValues() -> [String] {
        var strings: [String] = []
        
        for value in ApplicationAction.allCases
        {
            strings.append(value.rawValue)
        }
        
        return strings
    }
}
