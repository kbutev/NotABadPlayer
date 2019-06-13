//
//  Serializing.swift
//  NotABadPlayer
//
//  Created by Kristiyan Butev on 17.04.19.
//  Copyright © 2019 Kristiyan Butev. All rights reserved.
//

import Foundation

struct Serializing {
    public static func serialize<T: Encodable>(object: T) -> String? {
        if let encodedData = try? JSONEncoder().encode(object)
        {
            return encodedData.base64EncodedString()
        }
        
        return nil
    }
    
    public static func deserialize<T: Decodable>(fromData data: String) -> T? {
        if let encodedData = Data(base64Encoded: data)
        {
            if let result = try? JSONDecoder().decode(T.self, from: encodedData)
            {
                return result
            }
        }
        
        return nil
    }
}
