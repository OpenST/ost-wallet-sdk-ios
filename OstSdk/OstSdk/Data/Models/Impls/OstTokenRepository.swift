//
//  OstTokenRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenRepository: OstBaseCacheModelRepository, OstTokenModel {
    static let sharedToken = OstTokenRepository()
    private override init() {
        print("\n**************\ninit for 'OstTokenRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OstToken? {
        return try super.get(id) as? OstToken
    }
    
    func getAll(_ ids: Array<String>) -> [String : OstToken?] {
        return super.getAll(ids) as! [String : OstToken?]
    }
    
    override func save(_ tokenData: [String : Any], success: ((OstToken?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(tokenData, success: { (entity) in
            success?(entity as? OstToken)
        }, failure: failure)
    }
    
    func saveAll(_ tokenDataArray: Array<[String : Any]>, success: ((Array<OstToken>?, Array<OstToken>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(tokenDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OstToken>, failuarEntityArray as? Array<OstToken>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstTokenDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OstToken {
        return try OstToken(data)
    }
    
    override func saveEntity(_ entity: OstBaseEntity) -> Bool {
        return OstTokenDbQueries().save(entity as! OstToken)
    }
    
    override func saveAllEntities(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?,  Array<OstBaseEntity>?) {
        let (successArray, failuarArray) =  OstTokenDbQueries().saveAll(entities as! Array<OstToken>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
