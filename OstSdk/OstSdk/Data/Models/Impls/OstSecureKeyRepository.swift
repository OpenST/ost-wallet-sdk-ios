//
//  OstSecureKeyRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSecureKeyRepository: OstBaseCacheModelRepository, OstSecureKeyModel {
    
    static let sharedSecureKey = OstSecureKeyRepository()
    private override init() {
        print("\n**************\ninit for 'sharedSecureKey' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OstSecureKey? {
        return try super.get(id) as? OstSecureKey
    }
    
    override func save(_ secureKeyData: [String : Any], success: ((OstSecureKey?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(secureKeyData, success: { (entity) in
            success?(entity as? OstSecureKey)
        }, failure: failure)
    }
    
    // MARK: - override methods
    override func getEntity(_ data: [String : Any]) throws -> OstSecureKey {
        return OstSecureKey(data: (data["data"] as! Data), forKey: (data["key"] as! String))
    }
    
    override func saveEntity(_ entity: OstBaseEntity) -> Bool {
        return OstSecureKeyDbQueries().save(entity as! OstSecureKey)
    }
    
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstSecureKeyDbQueries()
    }
    
    override func saveDataInCache(key: String, val: OstBaseEntity) {
    }
    
    override func removeFromCache(key: String) {
    }
}
