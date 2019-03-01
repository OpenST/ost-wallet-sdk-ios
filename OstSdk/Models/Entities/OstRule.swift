//
//  OstRuleEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstRule: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "rule_id"
    
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
                forIdentifierKey: ENTITY_IDENTIFIER
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
    
    // TODO: check if the returen type should be Array or string
    /// Get rule ABI
    var abi : String? {
        return self.data["abi"] as? String
    }
}
