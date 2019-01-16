//
//  OstTokenHolderRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstTokenHolderRepository: OstBaseCacheModelRepository, OstTokenHolderModel{
    static let sharedTokenHolder = OstTokenHolderRepository()
    private override init() {
        print("\n**************\ninit for 'OstTokenHolderRepository' called\n**************\n")
    }
    
    //MARK: - protocol
    override func get(_ id: String) throws -> OstTokenHolder? {
        return try super.get(id) as? OstTokenHolder
    }
    
    func getAll(_ ids: Array<String>) -> [String : OstTokenHolder? ] {
        return super.getAll(ids) as! [String : OstTokenHolder?]
    }
    
    override func save(_ tokenHolderData: [String : Any], success: ((OstTokenHolder?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(tokenHolderData, success: { (entity) in
            success?(entity as? OstTokenHolder)
        }, failure: failure)
    }
    
    func saveAll(_ tokenHolderDataArray: Array<[String : Any]>, success: ((Array<OstTokenHolder>?, Array<OstTokenHolder>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(tokenHolderDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OstTokenHolder>, failuarEntityArray as? Array<OstTokenHolder>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstTokenHolderDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OstTokenHolder {
        return try OstTokenHolder(data)
    }
    
    override func saveEntity(_ entity: OstBaseEntity) -> Bool {
        return OstTokenHolderDbQueries().save(entity as! OstTokenHolder)
    }
    
    override func saveAllEntities(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?,  Array<OstBaseEntity>?) {
        let (successArray, failuarArray) =  OstTokenHolderDbQueries().saveAll(entities as! Array<OstTokenHolder>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
