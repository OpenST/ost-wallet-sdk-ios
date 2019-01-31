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
    
    override func getEntity(_ data: [String : Any?]) throws -> OstBaseEntity {
        return OstSecureKey(data: data["data"] as! Data, forKey: data["key"] as! String)
    }
}
