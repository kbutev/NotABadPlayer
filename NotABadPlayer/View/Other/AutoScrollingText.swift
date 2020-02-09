//
//  AutoScrollingText.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import UIKit

class AutoScrollingText: UILabel {
    var scrolling = AutoScrollingTextScrolling()
    var defaultScrollingParameters = AutoScrollingTextParameters()
    
    override var text: String? {
        get {
            return super.text
        }
        set {
            super.text = newValue
            
            if !scrolling.isCurrentlySettingText {
                onTextChanged()
            }
        }
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        self.lineBreakMode = .byClipping
    }
    
    public func retry() {
        if self.scrolling.isExhausted {
            // When manually retrying, restart and start scrolling immediately
            resetScrolling()
            self.scrolling.parameters.restartCapacity = 1
            self.scrolling.parameters.initialStartDelay = 0
            self.scrolling.start()
        }
    }
    
    private func resetScrolling() {
        self.scrolling.stop()
        self.scrolling = AutoScrollingTextScrolling(self)
        self.scrolling.parameters = defaultScrollingParameters
    }
    
    private func invalidateScrolling() {
        self.scrolling.stop()
        self.scrolling = AutoScrollingTextScrolling()
    }
    
    private func onTextChanged() {
        invalidateScrolling()
        
        weak var weakSelf = self
        
        DispatchQueue.main.async {
            if let strongSelf = weakSelf {
                strongSelf.resetScrolling()
                strongSelf.scrolling.start()
            }
        }
    }
}

// Contains the login of scrolling the text of an UILabel.
// To stop operating, deallocate the instance.
class AutoScrollingTextScrolling {
    weak var label: UILabel?
    
    var text: String {
        get {
            return label?.text ?? ""
        }
        set {
            label?.text = newValue
        }
    }
    
    var isExhausted: Bool {
        get {
            return _isExhausted
        }
    }
    
    // Used to tell if the current caller of self.text = ...
    var isCurrentlySettingText: Bool = false
    
    var doesNotNeedScrolling: Bool
    
    var parameters = AutoScrollingTextParameters()
    
    private var _originalText: String = ""
    
    private var _timesStarted: UInt = 0
    private var _isExhausted: Bool = false
    
    init(_ label: UILabel?=nil) {
        self.label = label
        self._originalText = label?.text ?? ""
        self.doesNotNeedScrolling = !(label?.isTruncated ?? false)
    }
    
    // Scroll operations
    
    public func start() {
        self.initialStart()
    }
    
    public func stop() {
        self.label = nil
        self.doesNotNeedScrolling = true
    }
    
    private func initialStart() {
        if self.doesNotNeedScrolling {
            return
        }
        
        self.perform(afterDelay: self.parameters.initialStartDelay) { [weak self] () in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.startFromBeginning()
        }
    }
    
    private func restart() {
        if doesNotNeedScrolling {
            return
        }
        
        scrollToStart()
        
        if let capacity = parameters.restartCapacity {
            if _timesStarted >= capacity || isExhausted {
                _isExhausted = true
                return
            }
        }
        
        _timesStarted += 1
        
        perform(afterDelay: parameters.restartWait) { [weak self] () in
            self?.startFromBeginning()
        }
    }
    
    private func startFromBeginning() {
        if doesNotNeedScrolling {
            return
        }
        
        _timesStarted += 1
        
        scrollToStart()
        
        perform(afterDelay: scrollInterval()) { [weak self] () in
            self?.scroll()
        }
    }
    
    private func scrollToStart() {
        self.isCurrentlySettingText = true
        self.text = self._originalText
        self.isCurrentlySettingText = false
    }
    
    private func scroll() {
        let atTheEnd = scrollNow()
        
        if !atTheEnd {
            perform(afterDelay: scrollInterval()) { [weak self] () in
                self?.scroll()
            }
        } else {
            finishScrolling()
        }
    }
    
    private func scrollNow() -> Bool {
        if hasReachedTheEnd() {
            return true
        }
        
        let now = self.text
        
        if !now.isEmpty {
            self.isCurrentlySettingText = true
            self.text = now.substring(from: 1)
            self.isCurrentlySettingText = false
        }
        
        return false
    }
    
    private func finishScrolling() {
        guard let delay = parameters.finishWait else {
            return
        }
        
        perform(afterDelay: delay) { [weak self] () in
            self?.restart()
        }
    }
    
    // Perform async operation
    
    private func perform(afterDelay delay: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: completion)
    }
    
    // Helpers
    
    private func scrollInterval() -> Double {
        return 0.1 * (1 / parameters.scrollSpeed)
    }
    
    private func hasReachedTheEnd() -> Bool {
        return !(label?.isTruncated ?? false)
    }
}

struct AutoScrollingTextParameters {
    var initialStartDelay: Double = 3.0
    var scrollSpeed: Double = 0.5
    var finishWait: TimeInterval? = 5.0
    var restartWait: TimeInterval = 10.0
    var restartCapacity: UInt? = 2
}
