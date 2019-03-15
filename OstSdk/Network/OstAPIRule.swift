/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

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
             onFailure?(OstError.init(fromApiResponse: failureResponse!))
        }
    }
}
