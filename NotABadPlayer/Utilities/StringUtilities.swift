//
//  StringUtilities.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 1.12.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

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
