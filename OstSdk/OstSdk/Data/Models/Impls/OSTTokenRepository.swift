//
//  OSTTokenRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTTokenRepository: OSTBaseCacheModelRepository, OSTTokenModel {
    static let sharedToken = OSTTokenRepository()
    private override init() {
        print("\n**************\ninit for 'OSTTokenRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OSTToken? {
        return try super.get(id) as? OSTToken
    }
    
    func getAll(_ ids: Array<String>) -> [String : OSTToken?] {
        return super.getAll(ids) as! [String : OSTToken?]
    }
    
    override func save(_ tokenData: [String : Any], success: ((OSTToken?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(tokenData, success: { (entity) in
            success?(entity as? OSTToken)
        }, failure: failure)
    }
    
    func saveAll(_ tokenDataArray: Array<[String : Any]>, success: ((Array<OSTToken>?, Array<OSTToken>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(tokenDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OSTToken>, failuarEntityArray as? Array<OSTToken>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTTokenDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OSTToken {
        return try OSTToken(jsonData: data)
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
        return OSTTokenDbQueries().save(entity as! OSTToken)
    }
    
    override func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?) {
        let (successArray, failuarArray) =  OSTTokenDbQueries().saveAll(entities as! Array<OSTToken>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
