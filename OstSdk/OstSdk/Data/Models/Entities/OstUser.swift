//
//  OstUserEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstUser: OstBaseEntity {
    
    init(_ params: [String: Any]) throws {
        super.init()
        
        let isValidParams = try validate(params)
        if (!isValidParams) {
            throw OstError.actionFailed("Object creation failed")
        }
        
        setParams(params)
    }
    
  
    public func getMultiSig() throws -> OstMultiSig? {
        if (self.multisig_id != nil) {
            return try OstSdk.getMultiSig(self.multisig_id!)
        }
        return nil
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
