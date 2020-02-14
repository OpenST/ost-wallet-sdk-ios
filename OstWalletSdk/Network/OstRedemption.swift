/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation


class OstRedemption: OstAPIBase{

    /// Get Single Redemption for user
    ///
    /// - Parameters:
    ///   - id : redemption id
    ///   - params: Fetch single redemption params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getRedemptionDetail(id:String,
                              params:[String : Any]?,
                              onSuccess:@escaping (([String: Any]?) -> Void),
                              onFailure:@escaping (([String: Any]?) -> Void)) throws {
        resourceURL =   "/users/" + self.userId + "/redemptions/" + id;
        var apiParams:[String : Any] = params ?? [:];
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: resourceURL, andParams: &apiParams, withUserId: self.userId)

        get(params: apiParams as [String : AnyObject],
            onSuccess:onSuccess,
            onFailure:onFailure);
    }
    
    /// Get Sku list for redemption
    ///
    /// - Parameters:
    ///   - params: Fetch sku list for redemption params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getRedeemableSkus(params:[String : Any]?,
                           onSuccess:@escaping (([String: Any]?) -> Void),
                           onFailure:@escaping (([String: Any]?) -> Void)) throws {
        resourceURL =   "/redeemable-skus/";
        var apiParams:[String : Any] = params ?? [:];
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: resourceURL, andParams: &apiParams, withUserId: self.userId)

        get(params: apiParams as [String : AnyObject],
            onSuccess:onSuccess,
            onFailure:onFailure);
    }
    
    /// Get Sku list for redemption
    ///
    /// - Parameters:
    ///   - id : sku id
    ///   - params: Fetch redeemable sku details params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getRedeemableSkuDetail(id: String,
                                params:[String : Any]?,
                                onSuccess:@escaping (([String: Any]?) -> Void),
                                onFailure:@escaping (([String: Any]?) -> Void)) throws {
        resourceURL =   "/redeemable-skus/"+id;
        var apiParams:[String : Any] = params ?? [:];
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: resourceURL, andParams: &apiParams, withUserId: self.userId)

        get(params: apiParams as [String : AnyObject],
            onSuccess:onSuccess,
            onFailure:onFailure);
    }
    
    
}
