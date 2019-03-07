//
//  OstFunctionEncoder.swift
//  OstSdk
//
//  Created by aniket ayachit on 22/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import BigInt

class OstFunctionEncoder {
    var functionName: String
    var args: Array<String>
    
    let json = """
    [{"constant":true,"inputs":[],"name":"name","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_spender","type":"address"},{"name":"_value","type":"uint256"}],"name":"approve","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"totalSupply","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"TOKEN_NAME","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_from","type":"address"},{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transferFrom","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"TOKEN_SYMBOL","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"decimals","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"TOKEN_DECIMALS","outputs":[{"name":"","type":"uint8"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"}],"name":"balanceOf","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"DECIMALSFACTOR","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"symbol","outputs":[{"name":"","type":"string"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[],"name":"TOKENS_MAX","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"remove","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_to","type":"address"},{"name":"_value","type":"uint256"}],"name":"transfer","outputs":[{"name":"success","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_proposedOwner","type":"address"}],"name":"initiateOwnershipTransfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"proposedOwner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":true,"inputs":[{"name":"_owner","type":"address"},{"name":"_spender","type":"address"}],"name":"allowance","outputs":[{"name":"remaining","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[],"name":"completeOwnershipTransfer","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"nonpayable","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_proposedOwner","type":"address"}],"name":"OwnershipTransferInitiated","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_newOwner","type":"address"}],"name":"OwnershipTransferCompleted","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_from","type":"address"},{"indexed":true,"name":"_to","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Transfer","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"name":"_owner","type":"address"},{"indexed":true,"name":"_spender","type":"address"},{"indexed":false,"name":"_value","type":"uint256"}],"name":"Approval","type":"event"}]
"""
    
    private(set) var formattedArgs: Array<ABIEncodable> = []
    
    private(set) var constructor: SolidityConstructor?
    private(set) var methods: [String: SolidityFunction] = [:]
    private(set) var events: [SolidityEvent] = []
    
    private(set) var abiObjects: [ABIObject] = []
    
    init(function: String, args: String...) {
        self.functionName = function
        self.args = args
    }
    
    func perform() throws -> String {
        abiObjects = try getAbiFromJsonString(json)
        parseABIObjects()
        try generateABIEncodableValues()
        return try encodeABI()
    }
    
    func getAbiFromJsonString(_ jsonString: String) throws -> [ABIObject] {
        let contractJsonABI = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        let abi: [ABIObject] = try decoder.decode([ABIObject].self, from: contractJsonABI)
        return abi
    }
    
    func parseABIObjects() {
        for abiObject in abiObjects {
            let handler = OstSolidityHandler()
            
            switch (abiObject.type, abiObject.stateMutability) {
            case (.event, _):
                if let event = SolidityEvent(abiObject: abiObject) {
                    add(event: event)
                }
            case (.function, let stateMutability?) where stateMutability.isConstant:
                if let function = SolidityConstantFunction(abiObject: abiObject, handler: handler) {
                    add(function: function)
                }
            case (.function, .nonpayable?):
                if let function = SolidityNonPayableFunction(abiObject: abiObject, handler: handler) {
                    add(function: function)
                }
            case (.function, .payable?):
                if let function = SolidityPayableFunction(abiObject: abiObject, handler: handler) {
                    add(function: function)
                }
            case (.constructor, _):
                self.constructor = SolidityConstructor(abiObject: abiObject, handler: handler)
            default:
                print("Could not parse abi object: \(abiObject)")
            }
        }
    }
    
    func add(function: SolidityFunction) {
        methods[function.name] = function
    }
    
    func add(event: SolidityEvent)  {
        events.append(event)
    }
    
    func generateABIEncodableValues() throws {
        guard let function = methods[functionName] else {
            throw OstError.init("u_fe_gaev_1", .functionNotFoundInABI)
        }
        let paramsStringArray: [[String]] = function.signature.groups(for: "\\([^<]*\\)")
        for paramsString in paramsStringArray {
            for param in paramsString {
                var text = param.replacingOccurrences(of: "(", with: "", options: NSString.CompareOptions.literal, range: nil)
                text = text.replacingOccurrences(of: ")", with: "", options: NSString.CompareOptions.literal, range: nil)
                let paramArray = text.split(separator: ",")
                for (index, type) in paramArray.enumerated() {
                    try formatInputValue(type: String(type), index: index)
                }
            }
        }
    }
    
    func formatInputValue(type: String, index: Int) throws {
        let element = args[index]
        if (type == "address") {
            let address = try EthereumAddress(hex: element, eip55: false)
            formattedArgs.append(address)
            
        }else if(type.starts(with: "uint") || type.starts(with: "int")) {
            let uintValue = BigInt(element)
            formattedArgs.append(uintValue!)
            
        }else if(type.starts(with: "bytes")) {
            
        }else if(type == "string") {
            formattedArgs.append(element)
        }
    }
    
    func encodeABI() throws -> String {
        guard let function = methods[functionName] else {
            throw OstError.init("u_fe_ea_1", .functionNotFoundInABI)
        }
        
        let _invocation = function.invokeWith(formattedArgs)
        guard let ethereumData = _invocation.encodeABI() else {
            throw OstError.init("u_fe_ea_2", .abiEncodeFailed)            
        }
        
        return ethereumData.hex()
    }
    
}
