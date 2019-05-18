//
//  Looper.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

struct LooperClientValue
{
    weak var client : LooperClient?
    
    init(_ client: LooperClient)
    {
        self.client = client
    }
    
    var value : LooperClient? {
        get {
            return client
        }
    }
}

protocol LooperClient : NSObject {
    func loop()
}

// Subscribe to this service to get updates repeatedly, in short intervals.
// The update is performed by calling the delegate method loop() and its called from the main thread always.
// This singleton is completely thread safe.
class Looper {
    public static let LOOP_INTERVAL_SECONDS: Double = 0.1
    public static let LOOP_CLEANUP_COUNT: Int = 100
    
    public static let shared: Looper = Looper()
    
    private var clients: [LooperClientValue] = []
    
    private var timer: Timer?
    private var loopCleanupCurrentCount: Int = 0
    
    private let serialQueue = DispatchQueue(label: "com.notabadplayer.Looper.serial")
    
    init() {
        timer = Timer.scheduledTimer(timeInterval: Looper.LOOP_INTERVAL_SECONDS,
                                     target: self,
                                     selector: #selector(loop),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    func subscribe(_ client: LooperClient) {
        serialQueue.sync {
            if !clientIsSubscribed(client)
            {
                clients.append(LooperClientValue(client))
            }
        }
    }
    
    func unsubscribe(_ client: LooperClient) {
        serialQueue.sync {
            removeClient(client)
        }
    }
    
    @objc private func loop() {
        // Timer calls this function in the main thread
        serialQueue.sync {
            for client in self.clients {
                client.value?.loop()
            }
            
            loopCleanupCurrentCount += 1
            
            if loopCleanupCurrentCount ==  Looper.LOOP_CLEANUP_COUNT
            {
                cleanup()
                loopCleanupCurrentCount = 0
            }
        }
    }
    
    private func clientIsSubscribed(_ client: LooperClient) -> Bool {
        var result: Bool = false
        
        result = clients.contains(where: {(element) -> Bool in
            if let value = element.value {
                return value == client
            }
            
            return false
        })
        
        return result
    }
    
    private func removeClient(_ client: LooperClient) {
        clients.removeAll(where: {(element) -> Bool in
            if let value = element.value {
                return value == client
            }
            
            return false
        })
    }
    
    private func cleanup() {
        clients.removeAll(where: {(element) -> Bool in
            return element.value == nil
        })
    }
}
