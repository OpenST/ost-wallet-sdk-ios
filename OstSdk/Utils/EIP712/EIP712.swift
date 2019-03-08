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
    private var types: [String: Any] = [:]
    private var primaryType: String = ""
    private var domain: [String: String] = [:]
    private var message: [String: Any] = [:]
    
    private static var INITIAL_BYTE: String {
        return "0x19"
    }
    private static var VERSION: String {
        return "0x01"
    }
    
    private static let DEFAULT_EIP712_DOMAIN_TYPE: Array<[String: String]> = [["name": "verifyingContract", "type": "address"]]
    
    init(types: [String: Any], primaryType: String, domain: [String: String], message: [String: Any]) {
        setPrimaryType(primaryType)
        setTypes(types)
        setDomain(domain)
        setMessage(message)
    }
    
    func getEIP712Hash() throws -> String {
        let domainSeparator = try hashData("EIP712Domain", data: self.domain);
        let message = try hashData(primaryType, data: self.message);
        
        return try SoliditySha3.getHash(["t": "bytes", "v": EIP712.INITIAL_BYTE ],
                                        ["t": "bytes", "v": EIP712.VERSION ],
                                        ["t": "bytes32", "v": domainSeparator ],
                                        ["t": "bytes32", "v": message])
        
    }
    
    private func setPrimaryType(_ primaryType: String) {
        self.primaryType = primaryType;
    }
    
    private func getPrimaryType() -> String {
        return primaryType
    }
    
    private func setDomain(_ domain: [String: String]) {
        self.domain = domain
    }
    
    private func getDomain() -> [String: String] {
        return domain
    }
    
    private func setMessage(_ message: [String: Any]) {
        self.message = message
    }
    
    private func getMessage() -> [String: Any] {
        return message
    }
    
    private func setTypes(_ types: [String: Any]) {
        self.types.merge(dict: types)
        
        let eip712Domain: Array<Any>? = self.types["EIP712Domain"] as? Array<Any> ?? nil
        if (eip712Domain == nil) {
            self.types["EIP712Domain"] = EIP712.DEFAULT_EIP712_DOMAIN_TYPE
        }
        
    }
    
    private func setDataType(_ dataType: String, dataTypeProperties: Any){
        self.types[dataType] = dataTypeProperties
    }
    
    private func getTypes() -> [String: Any] {
        return types
    }
    
    private func getDataType(_ dataType: String) -> Any? {
        return self.types[dataType]
    }
    
    private func getDataTypeDependencies(_ dataType: String, found: inout Array<String>) -> Array<String> {
        
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
    
    private func encodeDataType(_ dataType: String) -> String {
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
    
    private func hashDataType(_ dataType: String) -> String {
        
        let encodedDataType: String = encodeDataType(dataType);
        return encodedDataType.sha3(.keccak256)
    }
    
    private func encodeData(_ dataType: String, data: [String: Any]) throws -> String {
        
        var encTypes: Array<SolidityType> = []
        var encValues: Array<ABIEncodable> = []
        
        var solidityType: SolidityType
        var solidityValue: ABIEncodable
        
        // Add data-type hash
        solidityType = SolidityType.bytes(length: 32)
        encTypes.append(solidityType);
        solidityValue = try OstSolidityValue.getSolidtyValue( hashDataType(dataType), for: solidityType)
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
                let encodedDataString = try encodeData(fieldType, data: (value as! [String: String]))
                let data: Data = Data(hex: encodedDataString)
                let keccakValue = data.soliditySHA3Hash
                
                solidityValue = try OstSolidityValue.getSolidtyValue(keccakValue, for: solidityType)
                
                encTypes.append(solidityType);
                encValues.append(solidityValue);
                
            } else if (fieldType.lastIndexOf("]") == fieldType.count - 1) {
                throw OstError.init("u_eip712_eip712_ed_1", "Arrays currently unimplemented in encodeData")
                
            } else{
                solidityType = try SolidityType.typeFromString(fieldType)
                solidityValue = try OstSolidityValue.getSolidtyValue(value as! String, for: solidityType)
                
                encTypes.append(solidityType);
                encValues.append(solidityValue);
            }
        }
        
        let encodeParams = try ABI.encodeParameters(types: encTypes, values: encValues)
        return encodeParams
    }
    
    private func hashData(_ dataType: String, data: [String: Any]) throws -> String {
        let encodedDataString = try encodeData(dataType, data: data)
        let data: Data = Data(hex: encodedDataString)
        let keccakValue = data.soliditySHA3Hash
        return keccakValue;
    }
}
