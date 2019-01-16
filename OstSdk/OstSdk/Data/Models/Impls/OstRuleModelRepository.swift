//
//  OstRoleModelRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OstRuleModelRepository: OstBaseCacheModelRepository, OstRuleModel{
    
    static let sharedRule = OstRuleModelRepository()
    private override init() {
        print("\n**************\ninit for 'OstRuleModelRepository' called\n**************\n")
    }
    
    //MARK: - protocol
    override func get(_ id: String) throws -> OstRule? {
        return try super.get(id) as? OstRule ?? nil
    }
    
    func getAll(_ ids: Array<String>) -> [String : OstRule?] {
        return super.getAll(ids) as! [String: OstRule?]
    }
    
    override func save(_ ruleData: [String : Any], success: ((OstRule?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(ruleData, success: { (entity) in
            success?(entity as? OstRule)
        }, failure: failure)
    }
    
    func saveAll(_ ruleDataArray: Array<[String : Any]>, success: ((Array<OstRule>?, Array<OstRule>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(ruleDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OstRule>, failuarEntityArray as? Array<OstRule>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstRuleDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OstRule {
        return try OstRule(data)
    }
    
    override func saveEntity(_ entity: OstBaseEntity) -> Bool {
        return OstRuleDbQueries().save(entity as! OstRule)
    }
    
    override func saveAllEntities(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?,  Array<OstBaseEntity>?) {
        let (successArray, failuarArray) =  OstRuleDbQueries().saveAll(entities as! Array<OstRule>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
