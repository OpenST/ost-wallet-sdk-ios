//
//  OstToken.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstToken: OstBaseEntity {
    /// Entity identifier for user entity
    static let ENTITY_IDENTIFIER = "id"
        
    /// Store OstToken entity data in the data base and returns the OstToken model object
    ///
    /// - Parameter entityData: Entity data dictionary
    /// - Throws: OSTError
    class func storeEntity(_ entityData: [String: Any?]) throws {
        return try OstTokenRepository
            .sharedToken
            .insertOrUpdate(
                entityData,
                forIdentifierKey: ENTITY_IDENTIFIER
            )
    }
    
    /// Get OstToken object from given token id
    ///
    /// - Parameter tokenId: Token id
    /// - Returns: OstToken object
    /// - Throws: OSTError
    class func getById(_ tokenId: String) throws -> OstToken? {
        return try OstTokenRepository.sharedToken.getById(tokenId) as? OstToken
    }
    
    /// Initializer
    ///
    /// - Parameter tokenId: Token id
    /// - Throws: OstError
    class func initToken(_ tokenId: String) throws -> OstToken? {
        if let tokenObj = try OstToken.getById(tokenId) {
            return tokenObj
        }
        
        let userEntityData = [
            "id": tokenId,
            "status": OstUser.Status.CREATED.rawValue,
            "updated_timestamp": OstUtils.toString(Date.timestamp())
        ]
        
        try OstToken.storeEntity(userEntityData)
        return try OstToken.getById(tokenId)!
    }
    
    /// Get key identifier for id
    ///
    /// - Returns: Key identifier for id
    override func getIdKey() -> String {
        return OstToken.ENTITY_IDENTIFIER
    }
}

extension OstToken {
    /// Get token symbol
    var symbol: String? {
        return self.data["symbol"] as? String
    }
    
    /// Get token name
    var name: String? {
        return self.data["name"] as? String
    }
    
    /// Get token supply
    var totalSupply: String? {
        return OstUtils.toString(self.data["total_supply"] as Any?)
    }
    
    /// Get auxiliary chain id
    var auxiliaryChainId: String? {
        let auxiliaryChains: [[String: Any?]]? = self.data["auxiliary_chains"] as? [[String : Any?]]
        if (auxiliaryChains == nil || auxiliaryChains!.count == 0) {
            return nil
        }
        
        let auxiliaryChain = (auxiliaryChains?.first)!
        return OstUtils.toString(auxiliaryChain["chain_id"] as Any?)
    }
}
