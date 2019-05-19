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
        
        Logging.log(Serializing.self, "Error: cannot serialize object of type \(String(describing: T.self))")
        
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
        
        Logging.log(Serializing.self, "Error: cannot deserialize object of type \(String(describing: T.self))")
        
        return nil
    }
}
