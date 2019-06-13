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
    case MUTE_OR_UNMUTE;
    case MUTE;
    case FORWARDS_8;
    case FORWARDS_15;
    case FORWARDS_30;
    case FORWARDS_60;
    case BACKWARDS_8;
    case BACKWARDS_15;
    case BACKWARDS_30;
    case BACKWARDS_60;
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
