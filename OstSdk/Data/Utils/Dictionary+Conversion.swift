//
//  Dictionary+Conversion.swift
//  OstSdk
//
//  Created by aniket ayachit on 12/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

extension Dictionary{
    func toEncodedData() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject:self)
    }
    
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
    
    func toString() throws -> String? {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: self,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
           return theJSONText
        }
        throw OstError.actionFailed("Convert to JSON string failed.")
    }
}

