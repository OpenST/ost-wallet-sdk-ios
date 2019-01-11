//
//  OSTMultiSigR.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTMultiSigRepository: OSTBaseCacheModelRepository, OSTMultiSigModel {
    static let sharedMultiSig = OSTMultiSigRepository()
    private override init() {
        print("\n**************\ninit for 'OSTMultiSigRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OSTMultiSig? {
        return try super.get(id) as? OSTMultiSig
    }
    
    func getAll(_ ids: Array<String>) -> [String : OSTMultiSig?] {
        return super.getAll(ids) as! [String : OSTMultiSig?]
    }
    
    override func save(_ multiSigData: [String : Any], success: ((OSTMultiSig?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(multiSigData, success: { (entity) in
            success?(entity as? OSTMultiSig)
        }, failure: failure)
    }
    
    func saveAll(_ multiSigDataArray: Array<[String : Any]>, success: ((Array<OSTMultiSig>?, Array<OSTMultiSig>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(multiSigDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OSTMultiSig>, failuarEntityArray as? Array<OSTMultiSig>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTMultiSigDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OSTMultiSig {
        return try OSTMultiSig(jsonData: data)
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
        return OSTMultiSigDbQueries().save(entity as! OSTMultiSig)
    }
    
    override func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?) {
        let (successArray, failuarArray) =  OSTMultiSigDbQueries().saveAll(entities as! Array<OSTMultiSig>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
