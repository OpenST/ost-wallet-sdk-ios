/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

public class OstRule: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "address"
    
    /// Parent entity identifier for user entity
    static let ENTITY_PARENT_IDENTIFIER = "token_id"
    
    /// Store OstRule entity data in the data base and returns the OstRule model object
    ///
    /// - Parameter entityData: Entity data dictionary
    /// - Throws: OSTError
    class func storeEntity(_ entityData: [String: Any?]) throws {
        return try OstRuleModelRepository
            .sharedRule
            .insertOrUpdate(
                entityData,
                forIdentifierKey: ENTITY_IDENTIFIER,
                isSynchronous: true
            )
    }
    
    /// Get OstRule object from given user id
    ///
    /// - Parameter userId: User id
    /// - Returns: OstRule model object
    /// - Throws: OSTError
    class func getById(_ userId: String) throws -> OstRule? {
        return try OstRuleModelRepository.sharedRule.getById(userId) as? OstRule
    }
    
    class func getByParentId(_ parentId: String) throws -> [OstRule]? {
        return try OstRuleModelRepository.sharedRule.getByParentId(parentId) as? [OstRule]
    }
    
    /// Get key identifier for id
    ///
    /// - Returns: Key identifier for id
    override func getIdKey() -> String {
        return OstRule.ENTITY_IDENTIFIER
    }
    
    /// Get key identifier for parent id
    ///
    /// - Returns: Key identifier for parent id
    override func getParentIdKey() -> String {
        return OstRule.ENTITY_PARENT_IDENTIFIER
    }
}

public extension OstRule {
    /// Get token id
    var tokenId : String? {
        return OstUtils.toString(self.data["token_id"] as Any)
    }
    
    /// Get rule name
    var name : String? {
        return self.data["name"] as? String
    }
    
    /// Get rule address
    var address : String? {
        return self.data["address"] as? String
    }
    
    /// Get rule ABI
    var abi : String? {
        return self.data["abi"] as? String
    }
}
