//
//  OSTSecureKeyEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OSTSecureKey: OSTBaseEntity {
    private(set) var key: String
    private(set) var secData: Data
    
    init(data: Data, forKey key: String) {
        self.key = key
        self.secData = data
    }
}


extension OSTSecureKey {
    
    class func getSecKey(for address: String) throws -> OSTSecureKey? {
        do {
            guard let secureKey: OSTSecureKey = try OSTSecureKeyRepository.sharedSecureKey.get(address.addHexPrefix()) else {
                throw OSTError.actionFailed("Issue while getting Data for \(address)")
            }
            guard let decPrivateKey: Data = try OSTSecureStoreImpls(address: address.addHexPrefix()).decrypt(data: secureKey.secData) else {
                throw OSTError.actionFailed("Issue while getting Data for \(address)")
            }
            
            return OSTSecureKey(data: decPrivateKey, forKey: address.addHexPrefix())
        }catch let error {
            throw error
        }
    }
    
    class func storeSecKey(_ privateKey: String, forKey key: String, completion:((OSTSecureKey?, Error?) -> Void)?) {
        do {
            guard let privateKeyData: Data = privateKey.data(using: .utf8) else {
                completion?(nil, OSTError.actionFailed("storing secure key failed"))
                return
            }
            guard let encPrivateKey = try OSTSecureStoreImpls(address: key.addHexPrefix()).encrypt(data: privateKeyData)else {
                completion?(nil, OSTError.actionFailed("encrypting secure key failed"))
                return
            }
            
            let secKeyData: [String : Any] = ["key": key.addHexPrefix(), "data": encPrivateKey]
            OSTSecureKeyRepository.sharedSecureKey.save(secKeyData, success: { (secureKey) in
                if (secureKey == nil) {
                    completion?(nil, OSTError.actionFailed("storing secure key failed"))
                    return
                }
                do {
                    guard let decPrivateKey: Data = try OSTSecureStoreImpls(address: secureKey!.key.addHexPrefix()).decrypt(data: secureKey!.secData) else {
                        completion?(nil, OSTError.actionFailed("storing secure key failed"))
                        return
                    }
                    completion?(OSTSecureKey(data: decPrivateKey, forKey: secureKey!.key.addHexPrefix()), nil)
                }catch let error {
                    completion?(nil, error)
                }
            }, failure: { (error) in
                completion?(nil, OSTError.actionFailed("storing secure key failed"))
                return
            })
        }catch let error{
            completion?(nil, error)
        }
    }
}
