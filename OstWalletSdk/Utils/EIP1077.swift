/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import CryptoSwift

class EIP1077 {
    
    static let TX_FROM = "from"
    static let TX_TO = "to"
    static let TX_GAS = "gas"
    static let TX_GASPRICE = "gasPrice"
    static let TX_GASTOKEN = "gasToken"
    static let TX_NONCE = "nonce"
    static let TX_CALLPREFIX = "callPrefix"
    static let TX_OPERATIONTYPE = "operationType"
    static let TX_VALUE = "value"
    static let TX_DATA = "data"
    static let TX_EXTRAHASH = "extraHash"
    
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
        let sha3Args = generateSHA3Args()
        
        return try SoliditySha3.getHash(sha3Args)
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
}
