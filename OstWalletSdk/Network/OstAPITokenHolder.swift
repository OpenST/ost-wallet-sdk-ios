/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAPITokenHolder: OstAPIBase{
    private let tokenHolderApiResourceBase: String
    
    /// Initialize
    ///
    /// - Parameter userId: User id
    override init(userId: String) {
        self.tokenHolderApiResourceBase = "/users/\(userId)/token-holder"
        super.init(userId: userId)
    }
    
    /// Get token holder from server
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OstError
    func getTokenHolder(onSuccess:((OstTokenHolder) -> Void)?,
                        onFailure:((OstError) -> Void)?) throws {
        
        resourceURL = "\(self.tokenHolderApiResourceBase)"
        var params: [String: Any] = [:]
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
        get(params: params as [String: AnyObject],
             onSuccess: {(apiResponse) in
                do {
                    let tokenHolder = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(tokenHolder as! OstTokenHolder)
                }catch let error{
                    onFailure?(error as! OstError)
                }
        },
             onFailure: { (failureResponse) in
                onFailure?(OstError(fromApiResponse: failureResponse!))
        }
        )
    }
    
    /// Logout
    ///
    /// - Parameters:
    ///   - params: Logout parameters
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OstError
    func logout(params: [String: Any],
                onSuccess:((OstTokenHolder) -> Void)?,
                onFailure:((OstError) -> Void)?) throws {
        
        resourceURL = "\(self.tokenHolderApiResourceBase)/logout"
        var logoutParams: [String: Any] = params
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &logoutParams, withUserId: self.userId)
        
        post(params: logoutParams as [String: AnyObject],
            onSuccess: {(apiResponse) in
                do {
                    let tokenHolder = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(tokenHolder as! OstTokenHolder)
                }catch let error{
                    onFailure?(error as! OstError)
                }
        },
            onFailure: { (failureResponse) in
                onFailure?(OstError(fromApiResponse: failureResponse!))
        }
        )
    }
}
