//
//  OSTEconomyRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 02/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTEconomyRepository: OSTBaseCacheModelRepository, OSTEconomyModel {
    static let sharedEconomy = OSTEconomyRepository()
    private override init() {
        print("\n**************\ninit for 'OSTEconomyRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OSTEconomy? {
        return try super.get(id) as? OSTEconomy
    }
    
    func getAll(_ ids: Array<String>) -> [String : OSTEconomy?] {
        return super.getAll(ids) as! [String : OSTEconomy?]
    }
    
    override func save(_ economyData: [String : Any], success: ((OSTEconomy?) -> Void)?, failure: ((Error) -> Void)?) {
        return super.save(economyData, success: success as? ((OSTBaseEntity?) -> Void), failure: failure)
    }
    
    func saveAll(_ economyDataArray: Array<[String : Any]>, success: ((Array<OSTEconomy>?, Array<OSTEconomy>?) -> Void)?, failure: ((Error) -> Void)?) {
        return super.saveAll(economyDataArray, success: success as? ((Array<OSTBaseEntity>?, Array<OSTBaseEntity>?) -> Void), failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTEconomyDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OSTEconomy {
        return try OSTEconomy(jsonData: data)
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
        return OSTEconomyDbQueries().save(entity as! OSTEconomy)
    }
    
    override func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?) {
        let (successArray, failuarArray) =  OSTEconomyDbQueries().saveAll(entities as! Array<OSTEconomy>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
