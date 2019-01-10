//
//  OSTSecureKeyRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTSecureKeyRepository: OSTBaseCacheModelRepository, OSTSecureKeyModel {
    
    static let sharedSecureKey = OSTSecureKeyRepository()
    private override init() {
        print("\n**************\ninit for 'sharedSecureKey' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OSTSecureKey? {
        return try super.get(id) as? OSTSecureKey
    }
    
    override func save(_ secureKeyData: [String : Any], success: ((OSTSecureKey?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(secureKeyData, success: { (entity) in
            success?(entity as? OSTSecureKey)
        }, failure: failure)
    }
    
    // MARK: - override methods
    override func getEntity(_ data: [String : Any]) throws -> OSTSecureKey {
        return OSTSecureKey(data: (data["data"] as! Data), forKey: (data["key"] as! String))
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
        return OSTSecureKeyDbQueries().save(entity as! OSTSecureKey)
    }
    
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTSecureKeyDbQueries()
    }
    
    override func saveDataInCache(key: String, val: OSTBaseEntity) {
    }
    
    override func removeFromCache(key: String) {
    }
}
