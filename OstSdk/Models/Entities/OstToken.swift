//
//  OstToken.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstToken: OstBaseEntity {
 
    static func parse(_ entityData: [String: Any?]) throws -> OstToken? {
        return try OstTokenRepository.sharedToken.insertOrUpdate(entityData, forIdentifierKey: self.getEntityIdentiferKey()) as? OstToken
    }
    
    static func getEntityIdentiferKey() -> String {
        return "id"
    }
    
    class func getById(_ tokenId: String) throws -> OstToken? {
        return try OstTokenRepository.sharedToken.getById(tokenId) as? OstToken
    }
    
    override func getId(_ params: [String: Any?]? = nil) -> String {
        let paramData = params ?? self.data
        return OstUtils.toString(paramData[OstToken.getEntityIdentiferKey()] as Any?)!
    }
}

extension OstToken {
    var symbol: String? {
        return data["symbol"] as? String
    }
    
    var name: String? {
        return data["name"] as? String
    }
    
    var totalSupply: Int? {
        return OstUtils.toInt(data["total_supply"] as Any?)
    }
    
    var auxiliaryChainId: String? {
        let auxiliaryChains: [[String: Any?]]? = self.data["auxiliary_chains"] as? [[String : Any?]]
        if (auxiliaryChains == nil || auxiliaryChains!.count == 0) {
            return nil
        }
        
        let auxiliaryChain = (auxiliaryChains?.first)!
        return OstUtils.toString(auxiliaryChain["chain_id"] as Any?)
    }
}