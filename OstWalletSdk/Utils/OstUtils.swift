/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

public class OstUtils {
    
    class func toString(_ val: Any?) -> String? {
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
    
    class func toInt(_ val: Any?) -> Int? {
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
    
    public class func toJSONString(_ val: Any) throws -> String? {
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: val,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            return theJSONText
        }
        throw OstError("u_u_tjs_1", .jsonConversionFailed)
    }
    
    public class func toJSONObject(_ val: String) throws -> Any {
        let data = val.data(using: .utf8)!
        return try JSONSerialization.jsonObject(with: data, options: [])
    }
    
    public class func toEncodedData(_ val: Any) -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: val)
    }
    
    public class func toDecodedValue(_ val: Data) -> Any? {
        return NSKeyedUnarchiver.unarchiveObject(with: val)
    }
    
    class func buildNestedQuery(params: inout Array<HttpParam>, paramKeyPrefix:String, paramValObj: Any?) -> Array<HttpParam> {
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
    
    static let WEI_EXPONENT = 18
    typealias NumberComponents = (number: BigInt, exponent: Int)
    

    class func trimTrailingZeros(_ str:String) -> String {
        let subStr = Substring( str );
        return String(trimTrailing( subStr, suffix: "0"));
    }

    
    class func trimTrailingZeros(_ subStr:Substring) -> Substring {
        return trimTrailing( subStr, suffix: "0");
    }
    
    class func trimTrailing(_ subStr:Substring, suffix:String ) -> Substring {
        var str = subStr;
        while (str.hasSuffix(suffix) && str.count>0) {
            str = str.dropLast()
        }
        return str;
    }
    
    class func getNumberComponents(_ number: String) throws -> NumberComponents {
        let components = number.split(separator: ".")
        var exponent: Int
        var afterDecimalString: Substring = ""
        
        if components.count == 1 {
            exponent = 0
        }else if components.count == 2 {
            afterDecimalString = trimTrailing(components[1], suffix: "0");
            exponent = afterDecimalString.count
        }else {
            throw OstError("u_c_gnc_1", OstErrorText.invalidAmount)
        }
        
        guard let numberComponent  = BigInt("\( components[0])\(afterDecimalString)") else {
            throw OstError("u_c_gnc_2", OstErrorText.invalidAmount)
        }
        
        return (numberComponent, -(exponent))
    }
    
    //pragma mark Deci
    public static func toDeci( _ amount: String ) -> String {
        return convertNum(amount: amount, exponent:  1);
    }
    
    public static func fromDeci( _ amount:String ) -> String {
        return convertNum(amount: amount, exponent:  -1);
    }

    //pragma mark Centi
    public static func toCenti( _ amount: String ) -> String {
        return convertNum(amount: amount, exponent:  2);
    }
    
    public static func fromCenti( _ amount:String ) -> String {
        return convertNum(amount: amount, exponent:  -2);
    }
    
    //pragma mark Milli
    public static func toMilli( _ amount: String ) -> String {
        return convertNum(amount: amount, exponent:  3);
    }
    
    public static func fromMilli( _ amount:String ) -> String {
        return convertNum(amount: amount, exponent:  -3);
    }
    
    //pragma mark Micro
    public static func toMicro( _ amount: String ) -> String {
        return convertNum(amount: amount, exponent:  6);
    }
    
    public static func fromMicro( _ amount:String ) -> String {
        return convertNum(amount: amount, exponent:  -6);
    }

    //pragma mark Nano
    public static func toNano( _ amount: String ) -> String {
        return convertNum(amount: amount, exponent:  9);
    }
    
    public static func fromNano( _ amount:String ) -> String {
        return convertNum(amount: amount, exponent:  -9);
    }
    
    //pragma mark Pico
    public static func toPico( _ amount: String ) -> String {
        return convertNum(amount: amount, exponent:  12);
    }
    
    public static func fromPico( _ amount:String ) -> String {
        return convertNum(amount: amount, exponent:  -12);
    }
    
    //pragma mark Femto
    public static func toFemto( _ amount: String ) -> String {
        return convertNum(amount: amount, exponent:  15);
    }
    
    public static func fromFemto( _ amount:String ) -> String {
        return convertNum(amount: amount, exponent:  -15);
    }
    
    //pragma mark Atto
    public static func toAtto( _ amount: String ) -> String {
        return convertNum(amount: amount, exponent:  18);
    }
    
    public static func fromAtto( _ amount:String ) -> String {
        return convertNum(amount: amount, exponent:  -18);
    }
    
    //pragma mark convertor
    static func convertNum(amount: String, exponent:Int) -> String {
        
        if ( amount.count < 1) {
            return "";
        }
        var amountComponents:NumberComponents;
        do {
            amountComponents = try getNumberComponents( amount );
        } catch {
            return "";
        }

        let factorExponent = exponent + amountComponents.exponent;
        if ( factorExponent > -1 ) {
            //Number without any Fractional Part.
            return String((amountComponents.number * BigInt( 10 ).power( factorExponent )));
        }
        
        let num = amountComponents.number.description;
        
        //Number with only Fractional Part. No Int part.
        //Note: Remember, factorExponent is negative here.
        var diff = (-1 * factorExponent)  - num.count;
        if ( diff >= 0 ) {
            var val = num;
            while( diff > 0 ) {
                val = "0" + val;
                diff = diff - 1;
            }
            val = trimTrailingZeros(val)
            return "0." + val;
        }

        //Number with both Int and Fractional parts.
        //Note: Remember, factorExponent is negative here.
        diff = num.count + factorExponent;
        let intPart = num.substr(0, diff);
        var fractionalPart = num.substringAfter(diff);
        
        // Handel zeros fractional part.
        let fractionalBigInt = BigInt( fractionalPart );
        if ( nil == fractionalBigInt || fractionalBigInt! <= BigInt(0) ) {
            fractionalPart = "";
        } else {
            fractionalPart = trimTrailingZeros(fractionalPart);
        }
        
        if ( fractionalPart.count > 0 ) {
            fractionalPart = "." + fractionalPart;
        }
        
        return intPart! + fractionalPart;
        
    }
    
    @objc public class func getQueryParams(url:URL) -> [String:Any] {
        let query = url.query;
        var params:[String:Any] = [:];
        if ( nil == query ) {
            return params;
        }
        
        for pair in query!.components(separatedBy: "&") {
            let pairParts = pair.components(separatedBy: "=");
            var key:String = pairParts[0];
            key = key.removingPercentEncoding ?? key;
            key = key.replacingOccurrences(of: "[]", with: "");
            
            if ( pairParts.count < 2 ) {
                addToParamDict(dict: &params, key: key, value: "");
                continue;
            }
            let paramValue:String = pairParts[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            addToParamDict(dict: &params, key: key, value: paramValue);
        }
        return params;
    }
    
    class func addToParamDict(dict:inout [String:Any], key:String, value:Any) {
        if ( dict[key] == nil ) {
            dict[key] = value;
            return;
        }
        let dictValue = dict[key]!;
        if ( dictValue is Array<Any>) {
            var arrayVals = dictValue as! Array<Any>;
            arrayVals.append( value );
            dict[key] = arrayVals;
            return;
        }
        
        //Same key multiple values.
        dict[key] = [dictValue, value];
    }
    
    public class func dictionaryToJSONString(dictionary:[String:Any?]) -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: dictionary, options: [])
        guard jsonData != nil else {return nil}
        let jsonString = String(data: jsonData!, encoding: .utf8)
        guard jsonString != nil else {return nil}
        return jsonString! as String
    }
}

class HttpParam {
    var  paramName: String = ""
    var  paramValue: String = ""
    init() {}
    
    init(_ paramName: String, _ paramValue: String) {
        self.paramName = paramName;
        self.paramValue = paramValue;
    }
    
    func getParamValue() -> String {
        return paramValue;
    }
    
    func setParamValue(paramValue: String) {
        self.paramValue = paramValue
    }
    
    func getParamName() -> String {
        return paramName;
    }
    
    func setParamName(paramName: String) {
        self.paramName = paramName;
    }
    
}

