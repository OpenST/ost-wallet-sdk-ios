//
//  OSTRoleModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OSTRuleModelRepository: OSTBaseCacheModelRepository, OSTRuleModel{
    
    static let sharedRule = OSTRuleModelRepository()
    private override init() {
        print("\n**************\ninit for 'OSTRuleModelRepository' called\n**************\n")
    }
    
    //MARK: - protocol
    override func get(_ id: String) throws -> OSTRule? {
        return try super.get(id) as? OSTRule ?? nil
    }
    
    func getAll(_ ids: Array<String>) -> [String : OSTRule?] {
        return super.getAll(ids) as! [String: OSTRule?]
    }
    
    override func save(_ ruleData: [String : Any], success: ((OSTRule?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(ruleData, success: { (entity) in
            success?(entity as? OSTRule)
        }, failure: failure)
    }
    
    func saveAll(_ ruleDataArray: Array<[String : Any]>, success: ((Array<OSTRule>?, Array<OSTRule>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(ruleDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OSTRule>, failuarEntityArray as? Array<OSTRule>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OSTBaseDbQueries {
        return OSTRuleDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OSTRule {
        return try OSTRule(jsonData: data)
    }
    
    override func saveEntity(_ entity: OSTBaseEntity) -> Bool {
        return OSTRuleDbQueries().save(entity as! OSTRule)
    }
    
    override func saveAllEntities(_ entities: Array<OSTBaseEntity>) -> (Array<OSTBaseEntity>?,  Array<OSTBaseEntity>?) {
        let (successArray, failuarArray) =  OSTRuleDbQueries().saveAll(entities as! Array<OSTRule>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
