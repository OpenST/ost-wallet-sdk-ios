//
//  OstExecutableRuleRepository.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstExecutableRuleRepository: OstBaseCacheModelRepository, OstExecutableRuleModel {
    
    static let sharedExecutableRule = OstExecutableRuleRepository()
    private override init() {
        print("\n**************\ninit for 'OstExecutableRuleRepository' called\n**************\n")
    }
    
    override func get(_ id: String) throws -> OstExecutableRule? {
        return try super.get(id) as? OstExecutableRule
    }
    
    func getAll(_ ids: Array<String>) -> [String : OstExecutableRule?] {
        return super.getAll(ids) as! [String : OstExecutableRule?]
    }
    
    override func save(_ executableRuleData: [String : Any], success: ((OstExecutableRule?) -> Void)?, failure: ((Error) -> Void)?) {
        super.save(executableRuleData, success: { (entity) in
            success?(entity as? OstExecutableRule)
        }, failure: failure)
    }
    
    func saveAll(_ executableRuleDataArray: Array<[String : Any]>, success: ((Array<OstExecutableRule>?, Array<OstExecutableRule>?) -> Void)?, failure: ((Error) -> Void)?) {
        super.saveAll(executableRuleDataArray, success: { (successEntityArray, failuarEntityArray) in
            success?(successEntityArray as? Array<OstExecutableRule>, failuarEntityArray as? Array<OstExecutableRule>)
        }, failure: failure)
    }
    
    //MARK: - overrider
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstExecutableRuleDbQueries()
    }
    
    override func getEntity(_ data: [String : Any]) throws -> OstTokenHolder {
        return try OstTokenHolder(data)
    }
    
    override func saveEntity(_ entity: OstBaseEntity) -> Bool {
        return OstExecutableRuleDbQueries().save(entity as! OstExecutableRule)
    }
    
    override func saveAllEntities(_ entities: Array<OstBaseEntity>) -> (Array<OstBaseEntity>?,  Array<OstBaseEntity>?) {
        let (successArray, failuarArray) =  OstExecutableRuleDbQueries().saveAll(entities as! Array<OstExecutableRule>)
        return (successArray ?? nil, failuarArray ?? nil)
    }
}
