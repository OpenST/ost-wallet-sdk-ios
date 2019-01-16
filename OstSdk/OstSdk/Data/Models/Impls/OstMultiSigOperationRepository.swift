//
//  OstMultiSigOperationRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstMultiSigOperationRepository: OstBaseCacheModelRepository, OstMultiSigOperationModel {
    
    static let sharedMultiSigOperation = OstMultiSigOperationRepository()
    private override init() {
        print("\n**************\ninit for 'OstMultiSigOperationRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OstMultiSigOperation? {
        return try super.get(id) as? OstMultiSigOperation
    }
    
    func getAll(_ ids: Array<String>) -> [String : OstMultiSigOperation?] {
        return super.getAll(ids) as! [String : OstMultiSigOperation?]
    }
    
    override func save(_ multiSigOperationData: [String : Any], success: ((OstMultiSigOperation?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(multiSigOperationData, success: { (entity) in
            success?(entity as? OstMultiSigOperation)
        }, failure: failure)
    }
    
    func saveAll(_ multiSigOperationDataArray: Array<[String : Any]>, success: ((Array<OstMultiSigOperation>?, Array<OstMultiSigOperation>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(multiSigOperationDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OstMultiSigOperation>, failuarEntityArray as? Array<OstMultiSigOperation>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstMultiSigOperationDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OstTokenHolder {
        return try OstTokenHolder(data)
    }
    
    override func saveEntity(_ entity: OstBaseEntity) -> Bool {
        return OstMultiSigOperationDbQueries().save(entity as! OstMultiSigOperation)
    }
    
    override func saveAllEntities(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?,  Array<OstBaseEntity>?) {
        let (successArray, failuarArray) =  OstMultiSigOperationDbQueries().saveAll(entities as! Array<OstMultiSigOperation>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
