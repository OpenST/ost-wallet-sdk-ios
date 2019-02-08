//
//  OstSecureKeyRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSecureKeyRepository: OstBaseModelRepository {
    
    static let sharedSecureKey = OstSecureKeyRepository()
    private override init() {
        print("\n**************\ninit for 'sharedSecureKey' called\n**************\n")
    }

    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstSecureKeyDbQueries()
    }
    
    override func getEntity(_ data: [String : Any?]) throws -> OstSecureKey {
        return OstSecureKey(address: data["address"] as! String, privateKeyData: data["privateKeyData"] as! Data, isSecureEnclaveEnrypted: data["isSecureEnclaveEnrypted"] as! Bool)
    }
}
