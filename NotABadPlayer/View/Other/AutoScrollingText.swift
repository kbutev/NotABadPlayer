//
//  AutoScrollingText.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import UIKit

class AutoScrollingText: UILabel {
    let SCROLL_X_MOVE: CGFloat = 5
    
    var doesNotNeedScrolling = true
    
    var originalText: String = ""
    
    var width: CGFloat = 0
    
    var initialStartDelay: Double = 3.0
    var scrollSpeed: Double = 0.5
    var finishWait: TimeInterval? = 5.0
    var restartWait: TimeInterval = 10.0
    var restartCapacity: UInt? = 2
    
    private var timesStarted: UInt = 0
    private var isExhausted: Bool = false
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.lineBreakMode = .byClipping
        
        weak var weakSelf = self
        
        perform(afterDelay: initialStartDelay) {
            guard let strongSelf = weakSelf else {
                return
            }
            
            strongSelf.originalText = strongSelf.text ?? ""
            strongSelf.width = strongSelf.bounds.size.width
            
            strongSelf.doesNotNeedScrolling = !strongSelf.isTruncated
            
            if strongSelf.timesStarted == 0 {
                strongSelf.start()
            }
        }
    }
    
    // Operations
    
    public func retry() {
        if doesNotNeedScrolling {
            return
        }
        
        weak var weakSelf = self
        
        perform(afterDelay: 0) {
            guard let strongSelf = weakSelf else {
                return
            }
            
            if !strongSelf.isExhausted {
                return
            }
            
            strongSelf.timesStarted -= 1
            strongSelf.isExhausted = false
            
            strongSelf.start()
        }
    }
    
    private func restart() {
        if doesNotNeedScrolling {
            return
        }
        
        scrollToStart()
        
        if let capacity = restartCapacity {
            if timesStarted >= capacity {
                isExhausted = true
                return
            }
        }
        
        weak var weakSelf = self
        
        perform(afterDelay: restartWait) {
            weakSelf?.start()
        }
    }
    
    private func start() {
        if doesNotNeedScrolling {
            return
        }
        
        timesStarted += 1
        
        scrollToStart()
        
        weak var weakSelf = self
        
        perform(afterDelay: scrollInterval()) {
            weakSelf?.scroll()
        }
    }
    
    private func scrollToStart() {
        self.text = self.originalText
    }
    
    private func scroll() {
        let atTheEnd = scrollNow()
        
        weak var weakSelf = self
        
        if !atTheEnd {
            perform(afterDelay: scrollInterval()) {
                weakSelf?.scroll()
            }
        } else {
            finishScrolling()
        }
    }
    
    private func scrollNow() -> Bool {
        if hasReachedTheEnd() {
            return true
        }
        
        let now = self.text!
        self.text = now.substring(from: 1)
        
        return false
    }
    
    private func finishScrolling() {
        guard let delay = finishWait else {
            return
        }
        
        weak var weakSelf = self
        
        perform(afterDelay: delay) {
            weakSelf?.restart()
        }
    }
    
    // Helpers
    
    private func scrollInterval() -> Double {
        return 0.1 * (1 / scrollSpeed)
    }
    
    private func hasReachedTheEnd() -> Bool {
        if !self.isTruncated {
            return true
        }
        
        return self.text?.isEmpty ?? true
    }
    
    private func perform(afterDelay delay: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: completion)
    }
}
