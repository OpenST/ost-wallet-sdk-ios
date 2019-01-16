//
//  OstTokenHolderSessionRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenHolderSessionRepository: OstBaseCacheModelRepository, OstTokenHolderSessionModel {
    
    static let sharedTokenHolderSession = OstTokenHolderSessionRepository()
    private override init() {
        print("\n**************\ninit for 'OstTokenHolderSessionRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OstTokenHolderSession? {
        return try super.get(id) as? OstTokenHolderSession
    }
    
    func getAll(_ ids: Array<String>) -> [String : OstTokenHolderSession?] {
        return super.getAll(ids) as! [String : OstTokenHolderSession?]
    }
    
    override func save(_ tokenHolderSessionData: [String : Any], success: ((OstTokenHolderSession?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(tokenHolderSessionData, success: { (entity) in
            success?(entity as? OstTokenHolderSession)
        }, failure: failure)
    }
    
    func saveAll(_ tokenHolderSessionDataArray: Array<[String : Any]>, success: ((Array<OstTokenHolderSession>?, Array<OstTokenHolderSession>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(tokenHolderSessionDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OstTokenHolderSession>, failuarEntityArray as? Array<OstTokenHolderSession>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstTokenHolderSessionDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OstTokenHolder {
        return try OstTokenHolder(data)
    }
    
    override func saveEntity(_ entity: OstBaseEntity) -> Bool {
        return OstTokenHolderSessionDbQueries().save(entity as! OstTokenHolderSession)
    }
    
    override func saveAllEntities(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?,  Array<OstBaseEntity>?) {
        let (successArray, failuarArray) =  OstTokenHolderSessionDbQueries().saveAll(entities as! Array<OstTokenHolderSession>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
