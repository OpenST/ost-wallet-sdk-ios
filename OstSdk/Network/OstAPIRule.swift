//
//  OstAPIRule.swift
//  OstSdk
//
//  Created by aniket ayachit on 25/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPIRule: OstAPIBase {
    
    let ruleApiResourceBase: String
    override init(userId: String) {
        self.ruleApiResourceBase = "/rules"
        super.init(userId: userId)
    }
    
    func getRules(onSuccess: (() -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = self.ruleApiResourceBase
        
        var params: [String: Any] = [:]
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
        get(params: params as [String : AnyObject], onSuccess: { (apiResponse) in
            do {
                let _ = try OstAPIHelper.storeApiResponse(apiResponse!)
                onSuccess?()
            }catch let error{
                onFailure?(error as! OstError)
            }
        }) { (failureResponse) in
             onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
        }
    }
}
