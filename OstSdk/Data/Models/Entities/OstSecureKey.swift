//
//  OstSecureKeyEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstSecureKey: OstBaseEntity {
    public private(set) var key: String
    public private(set) var secData: Data
    
    var privateKey: String? {
        return String(data: secData, encoding: .utf8)
    }
    
    init(data: Data, forKey key: String) {
        self.key = key
        self.secData = data
        
        super.init()
    }
}

extension OstSecureKey {
    
    public class func getSecKey(for address: String) throws -> OstSecureKey? {
//        do {
//            guard let secureKey: OstSecureKey = try OstSecureKeyRepository.sharedSecureKey.getById(address.addHexPrefix()) as? OstSecureKey else {
//                throw OstError.actionFailed("Issue while getting Data for \(address)")
//            }
////            guard let decPrivateKey: Data = try OstSecureStoreImpls(address: address.addHexPrefix()).decrypt(data: secureKey.secData) else {
////                throw OstError.actionFailed("Issue while getting Data for \(address)")
////            }
//
//            return OstSecureKey(data: decPrivateKey, forKey: address.addHexPrefix())
//        }catch let error {
//            throw error
//        }
        throw OstError.actionFailed("")
    }
    
    public class func storeSecKeySync(_ privateKey: String, forKey key: String) throws -> OstSecureKey {
//        do {
//            guard let privateKeyData: Data = privateKey.data(using: .utf8) else {
//                throw OstError.actionFailed("storing secure key failed")
//            }
////            guard let encPrivateKey = try OstSecureStoreImpls(address: key.addHexPrefix()).encrypt(data: privateKeyData) else {
////                throw OstError.actionFailed("encrypting secure key failed")
////            }
//
//            let secureKey: OstSecureKey = OstSecureKey(data: encPrivateKey, forKey: key.addHexPrefix())
//            if OstSecureKeyRepository.sharedSecureKey.insertOrUpdateEntity(secureKey) != nil {
////                guard let decPrivateKey: Data = try OstSecureStoreImpls(address: secureKey.key.addHexPrefix()).decrypt(data: secureKey.secData) else {
////                    throw OstError.actionFailed("storing secure key failed")
////                }
//
//                return OstSecureKey(data: decPrivateKey, forKey: secureKey.key.addHexPrefix())
//            }
//
//            throw OstError.actionFailed("storing secure key failed")
//        }catch {
//            throw OstError.actionFailed("storing secure key failed")
//        }
        throw OstError.actionFailed("")
    }
}
