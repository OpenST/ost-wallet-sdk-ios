//
//  SoliditySHA3.swift
//  OstSdk
//
//  Created by aniket ayachit on 18/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import BigInt

public enum Sha3Error: Error {
    case invalidType(String?), invalidInput(String)
}

public class Utils {
    
    private static let TYPE_START_WITH_UINT = "uint"
    private static let TYPE_START_WITH_INT = "int"
    
    public static func SoliditySha3(_ args: Any...) throws -> String {
        var messageHex: String = ""
        for arg: Any in args {
            do {
                if arg is Array<Any> {
                    var index = 1
                    for ele:Any in arg as! Array<Any> {
                        print("******************************index : \(index)")
                        index += 1
                        print("ele: \(ele)")
                        let r = try processArg(ele)
                        messageHex += r
                        print("r : \(r)")
                        print("messageHex : \(messageHex)")
                    }
                }
            }catch let error {
                throw error
            }
        }
        
        return Data(hex: messageHex).soliditySHA3Hash.addHexPrefix()
    }
    
    fileprivate static func processArg(_ arg: Any...) throws -> String {
        var type: String = ""
        var value: Any = ""
        var arraySize: Int = 0
        
        for ele in arg {
            if ele is Array<Any> {
                let list: Array<Any> = ele as! Array<Any>;
                if (list.count >= 2) {
                    type = list.first as! String
                    value = list[1]
                }else {
                    throw Sha3Error.invalidType("")
                }
            } else if ele is [String: Any] {
                let dict: [String: Any] = ele as! [String: Any]
                
                if ((dict["t"] != nil || dict["type"] != nil) && (dict["v"] != nil || dict["value"] != nil)) {
                    type = (dict["t"] ?? dict["type"]) as! String
                    value = dict["v"] ?? dict["value"] as Any
                    
                }else {
                    throw Sha3Error.invalidType("")
                }
            } else {
               throw Sha3Error.invalidType("")
            }
            
            if (type.starts(with: Utils.TYPE_START_WITH_INT) || type.starts(with: Utils.TYPE_START_WITH_UINT)) &&
                (value is String) && !(value as! String).isMatch("^(-)?0x"){
                value = BigInt(stringLiteral: value as! String)
            }
            
            var hexVal: String = ""
            
            if value is Array<Any> {
                arraySize = (value as! Array<Any>).count
               
                for innerValue in value as! Array<Any> {
                    do {
                        hexVal += try solidityPack(type: type, value: innerValue, arraySize: arraySize);
                    }catch let error{
                        throw error
                    }
                }
                return hexVal
            }else {
                 hexVal += try solidityPack(type: type, value: value);
                return hexVal
            }
        }
        
        return ""
    }
    
    fileprivate static func solidityPack(type: String, value: Any, arraySize: Int = 0) throws -> String {
        var size: Int

        let _type = elementaryName(type).lowercased()
        
        if ("bytes" == _type) {
            if (value as! String).count%2 != 0 {
                throw Sha3Error.invalidInput("Invalid bytes character length \((value as! String).count)")
            }
            return (value as! String).stripHexPrefix()
        }else if ("string" == _type) {
            return (value as! String).stripHexPrefix().hexString
        }else if ("bool" == _type) {
            return (value as! Bool) ?  "01" : "00"
        }else if (type.starts(with: "address")) {
            if (arraySize != 0) {
                size = 64
            }else {
                size = 40
            }
            if (!(value as! String).isAddress) {
                throw Sha3Error.invalidInput("\(value) is not a valid address, or the checksum is invalid.");
            }
            return (value as! String).lowercased().stripHexPrefix().padLeft(totalWidth: size, with: "0")
        }
        
        size = parseTypeN(type);
        
        if (type.starts(with: "bytes")) {
            
            if (size == -1) {
                throw Sha3Error.invalidInput("bytes[] not yet supported in solidity")
            }
            
            // must be 32 byte slices when in an array
            if (arraySize != 0) {
                size = 32
            }
            
            if (size < 1 || size > 32 || size < ((value as! String).stripHexPrefix().count/2)) {
                throw Sha3Error.invalidInput("Invalid bytes \(size) for \(value)")
            }
            return (value as! String).stripHexPrefix().rightPad(totalWidth: size*2, with: "0")
            
        }else if (type.starts(with: "uint")) {
            if ((size % 8 != 0) || (size < 8) || (size > 256)) {
                throw Sha3Error.invalidInput("Invalid uint \(size) size");
            }
            
            do {
                let num: BigInt = try parseNumber(value)
                
                if (num.bitWidth > size) {
                    throw Sha3Error.invalidInput("Supplied uint exceeds width: \(size) vs \(num.bitWidth)")
                }
                
                if (num<BigInt("0")) {
                    throw Sha3Error.invalidInput("Supplied uint \(num) is negative")
                }
                return size != -1 ?
                    String(format: "%x", Int(num.description)!).padLeft(totalWidth: size / 8 * 2, with: "0") : String(format: "%x", Int(num.description)!)
            }catch let error {
                throw error
            }
        }else if (type.starts(with: "int")) {
            if ((size % 8 != 0) || (size < 8) || (size > 256)) {
                throw  Sha3Error.invalidInput("Invalid int \(size) size");
            }
            
            do {
                let num: BigInt = try parseNumber(value)
                if (num.bitWidth > size) {
                    throw Sha3Error.invalidInput("Supplied int exceeds width: \(size) vs \(num.bitWidth)")
                }
                
                if (num<BigInt("0")) {
                    let twosComplimentVal = twosCompliment(num)
                    return String(format: "%x", twosComplimentVal as! CVarArg)
                }else {
                    return size != -1 ?
                        String(format: "%x", Int(num.description)!).padLeft(totalWidth: size / 8 * 2, with: "0") : String(format: "%x", Int(num.description)!)
                }
            }catch let error {
                throw error
            }
        }else {
            // FIXME: support all other types
            throw Sha3Error.invalidType("Unsupported or invalid type: \(type)");
        }
    }
    
    fileprivate static func twosCompliment(_ original: BigInt) -> BigInt {
        // for negative BigInteger, top byte is negative
        let contents = Array(BigUInt(original).serialize())
        
        // prepend byte of opposite sign
        var result = contents
        result[0] = (contents[0] < 0) ? 0 : UInt8(-1);
        
        // this will be two's complement
        return BigInt(BigUInt(Data(bytes: result)))
    }
    
    static func parseNumber(_ value: Any) throws -> BigInt {
        if (value is String) {
            if ((value as! String).lowercased().hasPrefix("0x")) {
                return BigInt( (value as! String).stripHexPrefix(), radix: 16)!
            }else {
                return BigInt( (value as! String), radix: 10)!
            }
        }else if (value is BigInt) {
            return (value as! BigInt)
        }else {
            throw Sha3Error.invalidInput("\(value) is not a number")
        }
    }
    
    fileprivate static func parseTypeN(_ type: String) -> Int {
        let regex = "^\\D+(\\d+).*$"
        let isMatched: Bool = type.isMatch(regex);
        if (isMatched) {
            let mathches = type.groups(for: regex)
            if (mathches.count > 0) {
                return Int(mathches[0][1])!
            }
        }
        return -1;
    }
    
    
    fileprivate static func elementaryName(_ name: String) -> String {
        if (name.starts(with: "int[")) {
            return "int256"+name.substring(4)
        }else if ("int" == name) {
            return "int256"
        }else if (name.starts(with: "uint[")) {
            return "uint256"+name.substring(5)
        }else if ("uint" == name) {
            return "uint256"
        }else if (name.starts(with: "fixed[")) {
            return "fixed128x128"+name.substring(6)
        }else if ("fixed" == name) {
            return "fixed128x128"
        }else if (name.starts(with: "ufixed[")) {
            return "ufixed128x128"+name.substring(7)
        }else if ("ufixed" == name) {
            return "ufixed128x128"
        }
    
        return name
    }
    
}
