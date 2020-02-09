//
//  StringUtilities.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
}

class StringUtilities {
    static func secondsToString(_ durationInSeconds: Double) -> String {
        let time = Int(durationInSeconds)
        
        let hr = Int(time/60/60)
        let min = Int((time - (hr*60*60)) / 60)
        let sec = Int(time - (hr*60*60) - (min*60))
        
        if hr == 0
        {
            if min < 10
            {
                let strMin = "\(min)"
                let strSec = String(format: "%02d", sec)
                
                return "\(strMin):\(strSec)"
            }
            
            let strMin = String(format: "%02d", min)
            let strSec = String(format: "%02d", sec)
            
            return "\(strMin):\(strSec)"
        }
        
        let strHr = String(format: "%02d", hr)
        let strMin = String(format: "%02d", min)
        let strSec = String(format: "%02d", sec)
        
        return "\(strHr):\(strMin):\(strSec)"
    }
}
