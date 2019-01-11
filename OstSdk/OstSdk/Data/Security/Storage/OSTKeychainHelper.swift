//
//  OSTKeychainImpls.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import KeychainSwift

enum OSTKeychainError: Error {
    case invalidData
}

public class OSTKeychainHelper {
    var address: String
    public init(address: String) {
        self.address = address
    }
    
    fileprivate var namespace: String {
        let bundle: Bundle = Bundle(for: type(of: self))
        let namespace = bundle.infoDictionary!["CFBundleIdentifier"] as! String;
        print("OSTKeychainHelper :: namespace : \(namespace)")
        return namespace
    }
    
    public func encrypt(_ data: Data) throws -> Data? {
        guard let aesKey = getKey() else {
            throw OSTKeychainError.invalidData
        }
        let result = try OSTCryptoImpls().aesGCMEncrypt(aesKey: Array(aesKey), iv: Array("iv".data(using: .utf8)!), ahead: Array("iv".data(using: .utf8)!), dataToEncrypt: Array(data))
        return Data(bytes: result)
    }
    
    func getKey() -> Data? {
        
        guard let key = KeychainSwift(keyPrefix: namespace).getData(address) else {
            let key = try? OSTCryptoImpls().genSCryptKey(salt: namespace.data(using: .utf8)!, stringToCalculate: address)
            KeychainSwift(keyPrefix: namespace).set(key!, forKey: address, withAccess: .accessibleWhenUnlockedThisDeviceOnly)
            return KeychainSwift(keyPrefix: namespace).getData(address)
        }
        return key
    }
    
    public func decrypt(_ data: Data) throws -> Data {
        guard let aesKey = getKey() else {
            throw OSTKeychainError.invalidData
        }
        let result = try OSTCryptoImpls().aesGCMEncrypt(aesKey: Array(aesKey), iv: Array("iv".data(using: .utf8)!), ahead: Array("iv".data(using: .utf8)!), dataToEncrypt: Array(data))
        return Data(bytes: result)
    }
    
    func deleteKey() {
        KeychainSwift(keyPrefix: namespace).delete(address)
    }
}
