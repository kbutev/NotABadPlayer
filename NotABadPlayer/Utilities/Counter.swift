//
//  Counter.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 5.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

class Counter {
    private let synchronous: DispatchQueue
    
    private var _value: Int = 0
    
    init() {
        synchronous = DispatchQueue(label: "Counter.Counter")
    }
    
    init(identifier: String) {
        synchronous = DispatchQueue(label: "Counter.\(identifier)")
    }
    
    func value() -> Int {
        return synchronous.sync {
            return _value
        }
    }
    
    func isZero() -> Bool {
        return synchronous.sync {
            return _value == 0
        }
    }
    
    func increment() -> Int {
        return synchronous.sync {
            _value += 1
            return _value
        }
    }
    
    func decrement() -> Int {
        return synchronous.sync {
            _value -= 1
            return _value
        }
    }
}
