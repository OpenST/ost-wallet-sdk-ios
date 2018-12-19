//
//  EIP1077.swift
//  OstSdk
//
//  Created by aniket ayachit on 17/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import CryptoSwift

class EIP1077 {
    
    private static let TX_FROM = "from"
    private static let TX_TO = "to"
    private static let TX_GAS = "gas"
    private static let TX_GASPRICE = "gasPrice"
    private static let TX_GASTOKEN = "gasToken"
    private static let TX_NONCE = "nonce"
    private static let TX_CALLPREFIX = "callPrefix"
    private static let TX_OPERATIONTYPE = "operationType"
    private static let TX_VALUE = "value"
    private static let TX_DATA = "data"
    private static let TX_EXTRAHASH = "extraHash"
    
    private static let BYTES_BYTE_OFFSET = 5
    private static let UINT_BIT_OFFSET = 4
    private static let HEX_PREFIX = "0x"
    private static let BIT_NIBBLE_DIVISOR = 4
    private static let BYTE_NIBBLE_MULTIPLIER = 2
    
    var transaction: [String: String]
    var version: String
    init(transaction: [String: String], version: String = "0x00") {
        self.transaction = transaction
        self.version = version
    }
    
    func toEIP1077transactionHash() throws -> String {
        filterTransaction()
        let sha3Args: Array<[String: String]> = generateSHA3Args()
        do {
            let encodedString = try traverseSHA3Args(sha3Args)
            print("encodedString : \(encodedString)")
            return "0x"+Data(hex: encodedString).sha3(SHA3.Variant.keccak256).toHexString()
        }catch let error {
            throw error
        }
    }
    
    fileprivate func filterTransaction() {
        transaction[EIP1077.TX_VALUE] = transaction[EIP1077.TX_VALUE] ?? "0"
        transaction[EIP1077.TX_GASPRICE] = transaction[EIP1077.TX_GASPRICE] ?? "0"
        transaction[EIP1077.TX_GAS] = transaction[EIP1077.TX_GAS] ?? "0"
        transaction[EIP1077.TX_GASTOKEN] = transaction[EIP1077.TX_GASTOKEN] ?? "0"
        transaction[EIP1077.TX_OPERATIONTYPE] = transaction[EIP1077.TX_OPERATIONTYPE] ?? "0"
        transaction[EIP1077.TX_NONCE] = transaction[EIP1077.TX_NONCE] ?? "0"
        transaction[EIP1077.TX_TO] = transaction[EIP1077.TX_TO] ?? "0x"
        transaction[EIP1077.TX_DATA] = transaction[EIP1077.TX_DATA] ?? "0x"
        transaction[EIP1077.TX_EXTRAHASH] = transaction[EIP1077.TX_EXTRAHASH] ?? "0x00"
    }
    
    fileprivate func generateSHA3Args () -> Array<[String: String]> {
        var sha3Args: Array<[String: String]> = []
        sha3Args.append(["t": "bytes", "v": "0x19"])
        sha3Args.append(["t": "bytes", "v": version])
        sha3Args.append(["t": "address", "v": transaction[EIP1077.TX_FROM]!])
        sha3Args.append(["t": "address", "v": transaction[EIP1077.TX_TO]!])
        sha3Args.append(["t": "uint8", "v": transaction[EIP1077.TX_VALUE]!])
        sha3Args.append(["t": "bytes", "v": (Data(hex: transaction[EIP1077.TX_DATA]!).sha3(SHA3.Variant.keccak256).toHexString())])
        sha3Args.append(["t": "uint256", "v": transaction[EIP1077.TX_NONCE]!])
        sha3Args.append(["t": "uint8", "v": transaction[EIP1077.TX_GASPRICE]!])
        sha3Args.append(["t": "uint8", "v": transaction[EIP1077.TX_GAS]!])
        sha3Args.append(["t": "uint8", "v": transaction[EIP1077.TX_GASTOKEN]!])
        sha3Args.append(["t": "bytes4", "v": transaction[EIP1077.TX_CALLPREFIX]!])
        sha3Args.append(["t": "uint8", "v": transaction[EIP1077.TX_OPERATIONTYPE]!])
        sha3Args.append(["t": "bytes32", "v": transaction[EIP1077.TX_EXTRAHASH]!])
        
        return sha3Args
    }
    
    fileprivate func traverseSHA3Args(_ sha3Args: Array<[String: String]>) throws -> String {
        var encodedString: String = ""
        for arg in sha3Args {
            do {
                let val = try processSHA3Arg(type: arg["t"]!, value: arg["v"]!)
                encodedString = encodedString + val
            }catch let error{
                throw error
            }
        }
        return "0x"+encodedString
        
        
    }
    
    fileprivate func processSHA3Arg(type: String, value: String) throws -> String {
        var unitNibble: Int = 0
        var startIndex: String.Index
        
        if (type.starts(with: "uint")) {
            startIndex = type.index(type.startIndex, offsetBy: EIP1077.UINT_BIT_OFFSET)
            let unitBits = Int(type[startIndex..<type.endIndex])!
            
            unitNibble = unitBits/EIP1077.BIT_NIBBLE_DIVISOR;
            var hexVal: String = value
            if (!value.starts(with: EIP1077.HEX_PREFIX)) {
                let intVal: Int = Int(value)!
                hexVal = String(format: "%0\(unitNibble)X", intVal)
            }
            hexVal = hexVal.getFilteredHexString()
            if unitNibble < hexVal.count {
                throw OSTError.invalidInput("uint size exceed")
            }
            return hexVal.padLeft(totalWidth: unitNibble, with: "0")
            
        }else if (type.starts(with: "bytes")) {
            startIndex = type.index(type.startIndex, offsetBy: EIP1077.BYTES_BYTE_OFFSET)
            if (startIndex < type.endIndex) {
                let unitBytes = Int(type[startIndex..<type.endIndex])!
                unitNibble = unitBytes*EIP1077.BYTE_NIBBLE_MULTIPLIER;
                let filteredVal = value.getFilteredHexString()
                
                if unitNibble < filteredVal.count {
                    throw OSTError.invalidInput("bytes size exceed")
                }
                return filteredVal.padLeft(totalWidth: unitNibble, with: "0")
            }
        }
        
        return value.getFilteredHexString()
    }
}
