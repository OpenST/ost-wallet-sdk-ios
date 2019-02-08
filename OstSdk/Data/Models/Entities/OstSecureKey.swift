//
//  OstSecureKeyEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstSecureKey: OstBaseEntity {
    var address: String
    var privateKeyData: Data
    var isSecureEnclaveEnrypted: Bool
    
    var privateKey: String {
        return String(data: privateKeyData, encoding: .utf8)!
    }
    
    init(address: String, privateKeyData:Data, isSecureEnclaveEnrypted: Bool) {
        self.address = address
        self.privateKeyData =  privateKeyData
        self.isSecureEnclaveEnrypted = isSecureEnclaveEnrypted
        
        super.init()
    }
    
    func toDictionary() -> [String: Any] {
        return ["address": address,
                "privateKeyData": privateKeyData,
                "isSecureEnclaveEnrypted": isSecureEnclaveEnrypted]
    }
    
    override func getId(_ params: [String: Any]) -> String {
        return address
    }
}
