/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstRuleModelRepository: OstBaseModelCacheRepository{
    static let sharedRule = OstRuleModelRepository()
    static var tokenRules:[String:Set<String>] = [:];
    
    //MARK: - overrider
    
    /// Get DB query object
    ///
    /// - Returns: OstRuleDbQueries object
    override func getDBQueriesObj() -> OstBaseDbQueries {
        return OstRuleDbQueries()
    }
    
    /// Get OstRule entity object from entity data dictionary
    ///
    /// - Parameter data: Entity data dictionary
    /// - Returns: OstRule object
    /// - Throws: OSTError
    override func getEntity(_ data: [String : Any?]) throws -> OstRule {
        return try OstRule(data as [String : Any])
    }
    
    override func insertOrUpdateEntity(_ entity: OstBaseEntity, _ isSynchronous: Bool = false) {
        super.insertOrUpdateEntity( entity, isSynchronous );
        if ( nil == entity.parentId) {
            // Just for peace of mind.
            return;
        }
        
        var ruleAddresses:Set<String>? = OstRuleModelRepository.tokenRules[entity.parentId!];
        if ( nil == ruleAddresses) {
            // Create a new set.
            ruleAddresses = Set();
        }
        // Insert into set.
        ruleAddresses!.insert(entity.id);
        
        OstRuleModelRepository.tokenRules[entity.parentId!] = ruleAddresses;
    }


    override func getByParentId(_ parentId: String) throws -> [OstBaseEntity]? {
        
        let ruleAddresses:Set<String>? = OstRuleModelRepository.tokenRules[parentId];
        if ( nil == ruleAddresses ) {
            // Get from DB.
            return try super.getByParentId( parentId );
        }
        
        var results:[OstBaseEntity] = [];
        for ruleAddress in ruleAddresses! {
            let rule = try self.getById( ruleAddress );
            if ( nil == rule ) {
                continue;
            }
            
            results.append( rule! );
        }
        
        return results;
    }
    
}
