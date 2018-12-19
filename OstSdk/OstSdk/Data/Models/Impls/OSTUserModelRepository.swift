//
//  OSTUserModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OSTUserModelRepository: OSTBaseCacheModelRepository, OSTUserModel{

    static let sharedUser = OSTUserModelRepository()
    private override init() {
        print("\n**************\ninit for 'OSTUserModelRepository' called\n**************\n")
    }
    
    //MARK: - protocol
    override func get(_ id: String) throws -> OSTUser? {
        return try super.get(id) as? OSTUser
    }
    
    func getAll(_ ids: Array<String>) -> [String: OSTUser?] {
        return super.getAll(ids) as! [String: OSTUser?]
    }
    
    override func save(_ userData: [String : Any], success: ((OSTUser?) -> Void)?, failure: ((Error) -> Void)?) {
        return super.save(userData, success: success as? ((OSTBaseEntity?) -> Void), failure: failure)
    }
    
    func saveAll(_ userDataArray: Array<[String: Any]>, success: ((Array<OSTUser>?, Array<OSTUser>?) -> Void)?, failure: ((Error) -> Void)?) {
        return super.saveAll(userDataArray, success: success as? ((Array<OSTBaseEntity>?, Array<OSTBaseEntity>?) -> Void), failure: failure)
    }

    //MARK: - overrider
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTUserDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OSTUser {
        return try OSTUser(jsonData: data)
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
         return OSTUserDbQueries().save(entity as! OSTUser)
    }
    
    override func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?) {
        let (successArray, failuarArray) =  OSTUserDbQueries().saveAll(entities as! Array<OSTUser>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
