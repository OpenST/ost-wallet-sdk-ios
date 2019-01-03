//
//  OSTMultiSigOperationRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTMultiSigOperationRepository: OSTBaseCacheModelRepository, OSTMultiSigOperationModel {
    
    static let sharedMultiSigOperation = OSTMultiSigOperationRepository()
    private override init() {
        print("\n**************\ninit for 'OSTMultiSigOperationRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OSTMultiSigOperation? {
        return try super.get(id) as? OSTMultiSigOperation
    }
    
    func getAll(_ ids: Array<String>) -> [String : OSTMultiSigOperation?] {
        return super.getAll(ids) as! [String : OSTMultiSigOperation?]
    }
    
    override func save(_ multiSigOperationData: [String : Any], success: ((OSTMultiSigOperation?) -> Void)?, failure: ((Error) -> Void)?) {
        return super.save(multiSigOperationData, success: success as? ((OSTBaseEntity?) -> Void), failure: failure)
    }
    
    func saveAll(_ multiSigOperationDataArray: Array<[String : Any]>, success: ((Array<OSTMultiSigOperation>?, Array<OSTMultiSigOperation>?) -> Void)?, failure: ((Error) -> Void)?) {
        return super.saveAll(multiSigOperationDataArray, success: success as? ((Array<OSTBaseEntity>?, Array<OSTBaseEntity>?) -> Void), failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTMultiSigOperationDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OSTTokenHolder {
        return try OSTTokenHolder(jsonData: data)
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
        return OSTMultiSigOperationDbQueries().save(entity as! OSTMultiSigOperation)
    }
    
    override func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?) {
        let (successArray, failuarArray) =  OSTMultiSigOperationDbQueries().saveAll(entities as! Array<OSTMultiSigOperation>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
