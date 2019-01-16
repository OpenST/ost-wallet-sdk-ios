//
//  OstUserModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstUserModelRepository: OstBaseCacheModelRepository, OstUserModel{

    static let sharedUser = OstUserModelRepository()
    private override init() {
        print("\n**************\ninit for 'OstUserModelRepository' called\n**************\n")
    }
    
    //MARK: - protocol
    override func get(_ id: String) throws -> OstUser? {
        return try super.get(id) as? OstUser
    }
    
    func getAll(_ ids: Array<String>) -> [String: OstUser?] {
        return super.getAll(ids) as! [String: OstUser?]
    }
    
    override func save(_ userData: [String : Any], success: ((OstUser?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(userData, success: { (entity) in
            success?(entity as? OstUser)
        }, failure: failure)
    }
    
    func saveAll(_ userDataArray: Array<[String: Any]>, success: ((Array<OstUser>?, Array<OstUser>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(userDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OstUser>, failuarEntityArray as? Array<OstUser>)
        }, failure: failure)
    }

    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstUserDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OstUser {
        return try OstUser(data)
    }
    
    override func saveEntity(_ entity: OstBaseEntity) -> Bool {
         return OstUserDbQueries().save(entity as! OstUser)
    }
    
    override func saveAllEntities(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?,  Array<OstBaseEntity>?) {
        let (successArray, failuarArray) =  OstUserDbQueries().saveAll(entities as! Array<OstUser>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
