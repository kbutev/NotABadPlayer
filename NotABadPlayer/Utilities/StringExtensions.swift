//
//  StringExtensions.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 19.05.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

extension String
{
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
    
    func stringByReplacingFirstOccurrenceOfString(target: String, replaceString: String) -> String
    {
        if let range = self.range(of: target)
        {
            return self.replacingCharacters(in: range, with: replaceString)
        }
        
        return self
    }
}
