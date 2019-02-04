//
//  OstUtils.swift
//  OstSdk
//
//  Created by aniket ayachit on 15/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstUtils {
    
    static func toString(_ val: Any?) -> String? {
        if val == nil {
            return nil
        }
        if (val is String){
            return (val as! String)
        }else if (val is Int){
            return String(val as! Int)
        }
        return nil
    }
    
    static func toInt(_ val: Any?) -> Int? {
        if val == nil {
            return nil
        }
        if (val is Int){
            return (val as! Int)
        }else if (val is String){
            return Int(val as! String)
        }
        return nil
    }
    
    static func toJSONString(_ val: Any) throws -> String? {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: val,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            return theJSONText
        }
        throw OstError.actionFailed("Convert to JSON string failed.")
    }
    
    static func toJSONObject(_ val: String) throws -> Any {
        let data = val.data(using: .utf8)!
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
    
    static func toEncodedData(_ val: Any) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: val)
    }
    
    static func toDecodedValue(_ val: Data) -> Any? {
        return NSKeyedUnarchiver.unarchiveObject(with: val)
    }
}
