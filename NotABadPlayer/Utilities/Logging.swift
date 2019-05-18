//
//  Logging.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 6.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class Logging
{
    class func log<T>(_ source: T.Type, _ message: String) {
        NSLog("[\(String(describing: T.self))] \(message)")
    }
}
