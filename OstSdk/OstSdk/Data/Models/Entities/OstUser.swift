//
//  OstUserEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstUser: OstBaseEntity {
    
    static func parse(_ entityData: [String: Any?]) throws -> OstUser? {
        return try OstUserModelRepository.sharedUser.insertOrUpdate(entityData, forIdentifier: self.getEntityIdentifer()) as? OstUser ?? nil
    }
    
    static func getEntityIdentifer() -> String {
        return "id"
    }

    public func getMultiSig() throws -> OstMultiSig? {
        if (self.multisig_id != nil) {
            return try OstMultiSigRepository.sharedMultiSig.getById(self.multisig_id!) as? OstMultiSig
        }
        return nil
    }
    
    override func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstUser.getEntityIdentifer()])!
    }
}

public extension OstUser {
    var name: String? {
        return data["name"] as? String ?? nil
    }
    
    var token_holder_id: String? {
        return data["token_holder_id"] as? String ?? nil
    }
    
    var multisig_id: String? {
        return data["multisig_id"] as? String ?? nil
    }
    
    var token_id: String? {
        return data["token_id"] as? String ?? nil
    }
}
