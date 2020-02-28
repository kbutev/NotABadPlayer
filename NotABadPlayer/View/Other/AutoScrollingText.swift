//
//  AutoScrollingText.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 9.02.20.
//  Copyright © 2020 Kristiyan Butev. All rights reserved.
//

import UIKit

class AutoScrollingText: UILabel {
    public var defaultScrollingParameters = AutoScrollingTextParameters()
    private var scrolling = AutoScrollingTextScrolling()
    
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
    public var parameters = AutoScrollingTextParameters()
    
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
    
    private weak var label: UILabel?
    private var _doesNotNeedScrolling: Bool
    private var _originalText: String = ""
    private var _timesStarted: UInt = 0
    private var _isExhausted: Bool = false
    
    init(_ label: UILabel?=nil) {
        self.label = label
        self._originalText = label?.text ?? ""
        self._doesNotNeedScrolling = !(label?.isTruncated ?? false)
    }
    
    // Scroll operations
    
    public func start() {
        initialStart()
    }
    
    public func stop() {
        self.label = nil
        self._doesNotNeedScrolling = true
    }
    
    private func initialStart() {
        if self._doesNotNeedScrolling {
            return
        }
        
        self.perform(afterDelay: self.parameters.initialStartDelay) { [weak self] () in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.startScrollingFromBeginning()
        }
    }
    
    private func restart() {
        if _doesNotNeedScrolling {
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
            self?.startScrollingFromBeginning()
        }
    }
    
    private func startScrollingFromBeginning() {
        if _doesNotNeedScrolling {
            return
        }
        
        _timesStarted += 1
        
        scrollToStart()
        
        perform(afterDelay: scrollInterval()) { [weak self] () in
            self?.scrollUpdate()
        }
    }
    
    private func scrollToStart() {
        self.isCurrentlySettingText = true
        self.text = self._originalText
        self.isCurrentlySettingText = false
    }
    
    private func scrollUpdate() {
        if hasReachedTheEnd() {
            finishScrolling()
            return
        }
        
        scrollUpdateNow()
        
        perform(afterDelay: scrollInterval()) { [weak self] () in
            self?.scrollUpdate()
        }
    }
    
    private func scrollUpdateNow() {
        let now = self.text
        
        if !now.isEmpty {
            self.isCurrentlySettingText = true
            self.text = now.substring(from: 1)
            self.isCurrentlySettingText = false
        }
    }
    
    private func finishScrolling() {
        guard let delay = parameters.finishWait else {
            return
        }
        
        perform(afterDelay: delay) { [weak self] () in
            self?.restart()
        }
    }
    
    // Helpers
    
    private func perform(afterDelay delay: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay, execute: completion)
    }
    
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
