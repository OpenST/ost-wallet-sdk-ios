//
//  OstMultiSigR.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstMultiSigRepository: OstBaseCacheModelRepository, OstMultiSigModel {
    static let sharedMultiSig = OstMultiSigRepository()
    private override init() {
        print("\n**************\ninit for 'OstMultiSigRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OstMultiSig? {
        return try super.get(id) as? OstMultiSig
    }
    
    func getAll(_ ids: Array<String>) -> [String : OstMultiSig?] {
        return super.getAll(ids) as! [String : OstMultiSig?]
    }
    
    override func save(_ multiSigData: [String : Any], success: ((OstMultiSig?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(multiSigData, success: { (entity) in
            success?(entity as? OstMultiSig)
        }, failure: failure)
    }
    
    func saveAll(_ multiSigDataArray: Array<[String : Any]>, success: ((Array<OstMultiSig>?, Array<OstMultiSig>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(multiSigDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OstMultiSig>, failuarEntityArray as? Array<OstMultiSig>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstMultiSigDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OstMultiSig {
        return try OstMultiSig(data)
    }
    
    override func saveEntity(_ entity: OstBaseEntity) -> Bool {
        return OstMultiSigDbQueries().save(entity as! OstMultiSig)
    }
    
    override func saveAllEntities(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?,  Array<OstBaseEntity>?) {
        let (successArray, failuarArray) =  OstMultiSigDbQueries().saveAll(entities as! Array<OstMultiSig>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
