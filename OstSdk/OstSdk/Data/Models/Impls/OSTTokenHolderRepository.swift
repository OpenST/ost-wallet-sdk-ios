//
//  OSTTokenHolderRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OSTTokenHolderRepository: OSTBaseCacheModelRepository, OSTTokenHolderModel{
    static let sharedTokenHolder = OSTTokenHolderRepository()
    private override init() {
        print("\n**************\ninit for 'OSTTokenHolderRepository' called\n**************\n")
    }
    
    //MARK: - protocol
    override func get(_ id: String) throws -> OSTTokenHolder? {
        return try super.get(id) as? OSTTokenHolder
    }
    
    func getAll(_ ids: Array<String>) -> [String : OSTTokenHolder? ] {
        return super.getAll(ids) as! [String : OSTTokenHolder?]
    }
    
    override func save(_ tokenHolderData: [String : Any], success: ((OSTTokenHolder?) -> Void)?, failure: ((Error) -> Void)?) {
        return super.save(tokenHolderData, success: success as? ((OSTBaseEntity?) -> Void), failure: failure)
    }
    
    func saveAll(_ tokenHolderDataArray: Array<[String : Any]>, success: ((Array<OSTTokenHolder>?, Array<OSTTokenHolder>?) -> Void)?, failure: ((Error) -> Void)?) {
        return super.saveAll(tokenHolderDataArray, success: success as? ((Array<OSTBaseEntity>?, Array<OSTBaseEntity>?) -> Void), failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTTokenHolderDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OSTTokenHolder {
        return try OSTTokenHolder(jsonData: data)
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
        return OSTTokenHolderDbQueries().save(entity as! OSTTokenHolder)
    }
    
    override func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?) {
        let (successArray, failuarArray) =  OSTTokenHolderDbQueries().saveAll(entities as! Array<OSTTokenHolder>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
