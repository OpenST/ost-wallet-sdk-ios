//
//  OstUtils.swift
//  OstSdk
//
//  Created by aniket ayachit on 15/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstUtils {
    
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
    
    public static func toJSONString(_ val: Any) throws -> String? {
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
    
    static func buildNestedQuery(params: inout Array<HttpParam>, paramKeyPrefix:String, paramValObj: Any?) -> Array<HttpParam> {
        if paramValObj is [String: Any?] {
            let paramsDict: [String: Any?] = (paramValObj as! [String: Any?])
            for key in paramsDict.keys.sorted(by: <) {
                let value: Any = paramsDict[key] as Any
                var prefix: String = "";
                if paramKeyPrefix.isEmpty {
                    prefix = key
                }else {
                    prefix = paramKeyPrefix + "[" + key + "]";
                }
                _ = OstUtils.buildNestedQuery(params: &params, paramKeyPrefix: prefix, paramValObj: value);
            }
        }else if paramValObj is Array<Any> {
            for obj in (paramValObj! as! Array<Any>) {
                let prefix: String = paramKeyPrefix + "[]"
                _ = OstUtils.buildNestedQuery(params: &params, paramKeyPrefix: prefix, paramValObj: obj)
            }
        }else {
            if(paramValObj == nil){
                params.append(HttpParam(paramKeyPrefix, ""));
            }else{
                params.append(HttpParam(paramKeyPrefix, OstUtils.toString(paramValObj)!));
            }
        }
        return params
    }
}

public class HttpParam {
    var  paramName: String = ""
    var  paramValue: String = ""
    init() {}
    
    public init(_ paramName: String, _ paramValue: String) {
        self.paramName = paramName;
        self.paramValue = paramValue;
    }
    
    public func getParamValue() -> String {
        return paramValue;
    }
    
    public func setParamValue(paramValue: String) {
        self.paramValue = paramValue
    }
    
    public func getParamName() -> String {
        return paramName;
    }
    
    public func setParamName(paramName: String) {
        self.paramName = paramName;
    }
    
}
