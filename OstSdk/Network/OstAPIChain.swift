/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAPIChain: OstAPIBase {
    let chainApiResourceBase: String
    
    /// Initializer
    ///
    /// - Parameter userId: User Id
    override init(userId: String) {
        self.chainApiResourceBase = "/chains"
        super.init(userId: userId)
    }
    
    /// Get chain. Make an API call and return data
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getChain(onSuccess: (([String: Any]) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        // Get current user
        guard let user: OstUser = try OstUser.getById(self.userId) else {
            throw OstError.init("n_ac_gc_1", "User entity not found for id \(userId). Please create user first. User OstSdk.setup")
        }
        
        // Get token associated with the user
        guard let token: OstToken = try OstToken.getById(user.tokenId!) else {
            throw OstError.init("n_ac_gc_2", "Token entity not found for id \(userId)")
        }
        
        let chainId: String? = token.auxiliaryChainId
        if (chainId == nil || chainId!.isEmpty) {
            throw OstError.init("n_ac_gc_3", "Chain id not found for id \(userId). Please contact OST support.")
        }
        
        resourceURL = chainApiResourceBase + "/" + chainId!
        var params: [String: Any] = [:]
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        get(params: params as [String : AnyObject],
            onSuccess: { (apiResponse) in
                let resultType = apiResponse!["result_type"] as! String
                if (resultType == "chain") {
                    onSuccess?(apiResponse![resultType] as! [String: Any])
                }else {
                    onFailure?(OstError.init("n_ac_gc_4", .unableToChainInformation))
                }
            },
            onFailure: { (failureResponse) in
                onFailure?(OstError.init(fromApiResponse: failureResponse!))
            }
        )
    }
    
    func getPricePoint(onSuccess: (([String: Any]) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        // Get current user
        guard let user: OstUser = try OstUser.getById(self.userId) else {
            throw OstError.init("n_ac_gpp_1", "User entity not found for id \(userId). Please create user first. User OstSdk.setup")
        }
        
        // Get token associated with the user
        guard let token: OstToken = try OstToken.getById(user.tokenId!) else {
            throw OstError.init("n_ac_gpp_2", "Token entity not found for id \(userId)")
        }
        
        let chainId: String? = token.auxiliaryChainId
        if (chainId == nil || chainId!.isEmpty) {
            throw OstError.init("n_ac_gpp_3", "Chain id not found for id \(userId). Please contact OST support.")
        }
        
        resourceURL = "\(chainApiResourceBase)/\(chainId!)/price-points"
        var params: [String: Any] = [:]
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        get(params: params as [String : AnyObject],
            onSuccess: { (apiResponse) in
                let resultType = apiResponse!["result_type"] as! String
                if (resultType == "price_point") {
                    onSuccess?(apiResponse![resultType] as! [String: Any])
                }else {
                    onFailure?(OstError.init("n_ac_gpp_4", .unableToChainInformation))
                }
        },
            onFailure: { (failureResponse) in
                onFailure?(OstError.init(fromApiResponse: failureResponse!))
        }
        )
    }
}
