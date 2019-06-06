/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAPISalt: OstAPIBase {
    
    let apiSaltResourceBase: String
    
    /// Initializer
    ///
    /// - Parameter userId: User id
    override init(userId: String) {
        apiSaltResourceBase = "/users/\(userId)/salts"
        super.init(userId: userId)
    }
    
    /// Get recovery key salt. Make an API call
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getRecoverykeySalt(onSuccess: (([String: Any]) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = apiSaltResourceBase + "/"
        var params: [String: Any] = [:]

        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
        get(params: params as [String: AnyObject],
            onSuccess: { (apiResponse) in                
                let resultType = apiResponse!["result_type"] as! String
                if (resultType == "salt") {
                    onSuccess?(apiResponse![resultType] as! [String: Any])
                }else {
                    onFailure?(OstError("n_ap_grks_1", .unableToGetSalt))
                }
            },
            onFailure: { (failureResponse) in
                onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
            }
        )
    }
}
