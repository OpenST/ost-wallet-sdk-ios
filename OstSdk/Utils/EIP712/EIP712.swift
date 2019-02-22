//
//  EIP712.swift
//  OstSdk
//
//  Created by aniket ayachit on 21/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import CryptoSwift
import EthereumKit

class EIP712 {
    var types: [String: Any] = [:]
    var primaryType: String = ""
    var domain: [String: String] = [:]
    var message: [String: Any] = [:]
    
    static var INITIAL_BYTE: String {
        return "0x19"
    }
    static var VERSION: String {
        return "0x01"
    }
    
    static let DEFAULT_EIP712_DOMAIN_TYPE: Array<[String: String]> = [["name": "verifyingContract", "type": "address"]]
    
    init(types: [String: Any], primaryType: String, domain: [String: String], message: [String: Any]) {
        setPrimaryType(primaryType)
        setTypes(types)
        setDomain(domain)
        setMessage(message)
    }
    
    func setPrimaryType(_ primaryType: String) {
        self.primaryType = primaryType;
    }
    
    func getPrimaryType() -> String {
        return primaryType
    }
    
    func setDomain(_ domain: [String: String]) {
        self.domain = domain
    }
    
    func getDomain() -> [String: String] {
        return domain
    }
    
    func setMessage(_ message: [String: Any]) {
        self.message = message
    }
    
    func getMessage() -> [String: Any] {
        return message
    }
    
    func setTypes(_ types: [String: Any]) {
        self.types.merge(dict: types)
        
        let eip712Domain: Array<Any>? = self.types["EIP712Domain"] as? Array<Any> ?? nil
        if (eip712Domain == nil) {
            self.types["EIP712Domain"] = EIP712.DEFAULT_EIP712_DOMAIN_TYPE
        }
        
    }
    
    func setDataType(_ dataType: String, dataTypeProperties: Any){
        self.types[dataType] = dataTypeProperties
    }
    
    func getTypes() -> [String: Any] {
        return types
    }
    
    func getDataType(_ dataType: String) -> Any? {
        return self.types[dataType]
    }
    
    func getDataTypeDependencies(_ dataType: String, found: inout Array<String>) -> Array<String> {
        
        let index = found.index(of: dataType);
        
        if index != nil {
            return [found[index!]]
        }
        guard let dataTypeProperties: Array<[String: String]> = getDataType(dataType) as? Array<[String: String]> else {
            return found
        }
        found.append(dataType)
        
        for field in dataTypeProperties {
            let depDataTypeDependencies = getDataTypeDependencies(field["type"]!, found: &found)
            for dep in depDataTypeDependencies{
                if !found.contains(dep) {
                    found.append(dataType)
                }
            }
        }
        return found
    }
    
    func encodeDataType(_ dataType: String) -> String {
        var found: Array<String> = []
        var deps = getDataTypeDependencies(dataType, found: &found);
        let index = deps.index(of: dataType)
        if (index != nil) {
            deps.remove(at: index!)
        }
        deps = deps.sorted { $0.compare($1) == ComparisonResult.orderedAscending }
        deps = [dataType] + deps;
        
        let types = getTypes()
        var result = ""
        
        for type in deps {
            var typeA: Array<String> = []
            let typeArray: Array<[String: String]> = types[type] as! Array<[String : String]>
            for obj in typeArray {
                typeA.append("\(obj["type"]!) \(obj["name"]!)")
            }
            result += "\(type)(\(typeA.joined(separator: ",")))"
        }
        
        return result
    }
    
    func hashDataType(_ dataType: String) -> String {
        
        let encodedDataType: String = encodeDataType(dataType);
        return encodedDataType.sha3(.keccak256)
    }
    
    func  encodeData(_ dataType: String, data: [String: Any]) throws -> String {
        
        var encTypes: Array<SolidityType> = []
        var encValues: Array<ABIEncodable> = []
        
        var solidityType: SolidityType
        var solidityValue: ABIEncodable
        
        // Add data-type hash
        solidityType = SolidityType.bytes(length: 32)
        encTypes.append(solidityType);
        solidityValue = try OstSolidityValue.getSolidtyValue( hashDataType(dataType), for: solidityType)
        Logger.log(message: "oThis.hashDataType(dataType)", parameterToPrint: hashDataType(dataType))
        encValues.append(solidityValue);
        
        // Add field contents
        let types = getTypes();
        let dataTypeProperties: Array<[String: String]> = getDataType(dataType) as! Array<[String: String]>
        for field in dataTypeProperties {
            let value = data[field["name"]!]!;
            let fieldType = field["type"]!
            if (fieldType == "string" || fieldType == "bytes") {
                solidityType = SolidityType.bytes(length: 32)
                
                var keccakValue: String = ""
                if ((value as! String).hasPrefix("0x")) {
                    let valueData = Data(hex: value as! String)
                    keccakValue = SHA3(variant: .keccak256).calculate(for: Array(valueData)).toHexString()
                }else {
                    keccakValue = (value as! String).sha3(.keccak256)
                }
                
                solidityValue = try OstSolidityValue.getSolidtyValue(keccakValue, for: solidityType)
                
                encTypes.append(solidityType);
                encValues.append(solidityValue);
                
            } else if (types[fieldType] != nil) {
                solidityType = SolidityType.bytes(length: 32)
                print("fieldType : ",fieldType)
                print("fieldValue : ",(value as! [String: String]))
                
                let encodedDataString = try encodeData(fieldType, data: (value as! [String: String]))
                let data: Data = Data(hex: encodedDataString)
                let keccakValue = data.soliditySHA3Hash
                print("value2 :", keccakValue)
                
                solidityValue = try OstSolidityValue.getSolidtyValue(keccakValue, for: solidityType)
                
                encTypes.append(solidityType);
                encValues.append(solidityValue);
                
            } else if (fieldType.lastIndexOf("]") == fieldType.count - 1) {
                throw OstError.actionFailed("Arrays currently unimplemented in encodeData")
                
            } else{
                solidityType = try SolidityType.typeFromString(fieldType)
                solidityValue = try OstSolidityValue.getSolidtyValue(value as! String, for: solidityType)
                
                encTypes.append(solidityType);
                print("value3 :", value as! String)
                encValues.append(solidityValue);
            }
        }
        
        let encodeParams = try ABI.encodeParameters(types: encTypes, values: encValues)
        print ("encodeParams :", encodeParams)
        return encodeParams
    }
    
    func hashData(_ dataType: String, data: [String: Any]) throws -> String {
        let encodedDataString = try encodeData(dataType, data: data)
        let data: Data = Data(hex: encodedDataString)
        let keccakValue = data.soliditySHA3Hash
        return keccakValue;
    }
    
    func getEIP712SignHash() throws -> String {
        
        let domainSeparator = try hashData("EIP712Domain", data: self.domain);
        print("Domain Seperator", domainSeparator);
        let message = try hashData(primaryType, data: self.message);
        print("message", message);
        
        return try Utils.SoliditySha3(["t": "bytes", "v": EIP712.INITIAL_BYTE ],
                                      ["t": "bytes", "v": EIP712.VERSION ],
                                      ["t": "bytes32", "v": domainSeparator ],
                                      ["t": "bytes32", "v": message])
        
    }
    
    func validate() -> Bool {
        return true
    }
    
}
