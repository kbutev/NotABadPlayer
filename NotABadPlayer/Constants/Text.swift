//
//  Strings.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 19.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

enum Text: String {
    public static let ARG_PLACEHOLDER = "@!"
    
    static func localizedText(_ string: String) -> String {
        return string
    }
    
    static func value(_ value: Text) -> String {
        return localizedText(value.rawValue)
    }
    
    static func value(_ value: Text, _ arg1: String) -> String {
        return localizedText(value.rawValue).stringByReplacingFirstOccurrenceOfString(target: Text.ARG_PLACEHOLDER, replaceString: arg1)
    }
    
    static func value(_ value: Text, _ arg1: String, _ arg2: String) -> String {
        var string = localizedText(value.rawValue)
        
        string = string.stringByReplacingFirstOccurrenceOfString(target: Text.ARG_PLACEHOLDER, replaceString: arg1)
        string = string.stringByReplacingFirstOccurrenceOfString(target: Text.ARG_PLACEHOLDER, replaceString: arg2)
        
        return string
    }
    
    // List of text values
    case Empty = "";
    case ListDescription = "@! tracks, duration @!";
    case NothingPlaying = "Nothing Playing";
    case ZeroTimer = "0:00";
    case DoubleZeroTimers = "0:00/0:00";
}
