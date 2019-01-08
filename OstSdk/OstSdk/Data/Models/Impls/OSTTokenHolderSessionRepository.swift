//
//  OSTTokenHolderSessionRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTTokenHolderSessionRepository: OSTBaseCacheModelRepository, OSTTokenHolderSessionModel {
    
    static let sharedTokenHolderSession = OSTTokenHolderSessionRepository()
    private override init() {
        print("\n**************\ninit for 'OSTTokenHolderSessionRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OSTTokenHolderSession? {
        return try super.get(id) as? OSTTokenHolderSession
    }
    
    func getAll(_ ids: Array<String>) -> [String : OSTTokenHolderSession?] {
        return super.getAll(ids) as! [String : OSTTokenHolderSession?]
    }
    
    override func save(_ tokenHolderSessionData: [String : Any], success: ((OSTTokenHolderSession?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(tokenHolderSessionData, success: { (entity) in
            success?(entity as? OSTTokenHolderSession)
        }, failure: failure)
    }
    
    func saveAll(_ tokenHolderSessionDataArray: Array<[String : Any]>, success: ((Array<OSTTokenHolderSession>?, Array<OSTTokenHolderSession>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(tokenHolderSessionDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OSTTokenHolderSession>, failuarEntityArray as? Array<OSTTokenHolderSession>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTTokenHolderSessionDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OSTTokenHolder {
        return try OSTTokenHolder(jsonData: data)
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
        return OSTTokenHolderSessionDbQueries().save(entity as! OSTTokenHolderSession)
    }
    
    override func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?) {
        let (successArray, failuarArray) =  OSTTokenHolderSessionDbQueries().saveAll(entities as! Array<OSTTokenHolderSession>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
