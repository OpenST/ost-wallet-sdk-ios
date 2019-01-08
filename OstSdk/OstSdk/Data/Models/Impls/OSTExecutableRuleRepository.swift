//
//  OSTExecutableRuleRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OSTExecutableRuleRepository: OSTBaseCacheModelRepository, OSTExecutableRuleModel {
    
    static let sharedExecutableRule = OSTExecutableRuleRepository()
    private override init() {
        print("\n**************\ninit for 'OSTExecutableRuleRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OSTExecutableRule? {
        return try super.get(id) as? OSTExecutableRule
    }
    
    func getAll(_ ids: Array<String>) -> [String : OSTExecutableRule?] {
        return super.getAll(ids) as! [String : OSTExecutableRule?]
    }
    
    override func save(_ executableRuleData: [String : Any], success: ((OSTExecutableRule?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(executableRuleData, success: { (entity) in
            success?(entity as? OSTExecutableRule)
        }, failure: failure)
    }
    
    func saveAll(_ executableRuleDataArray: Array<[String : Any]>, success: ((Array<OSTExecutableRule>?, Array<OSTExecutableRule>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(executableRuleDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OSTExecutableRule>, failuarEntityArray as? Array<OSTExecutableRule>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTExecutableRuleDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OSTTokenHolder {
        return try OSTTokenHolder(jsonData: data)
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
        return OSTExecutableRuleDbQueries().save(entity as! OSTExecutableRule)
    }
    
    override func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?) {
        let (successArray, failuarArray) =  OSTExecutableRuleDbQueries().saveAll(entities as! Array<OSTExecutableRule>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
