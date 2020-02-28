/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAPIUser: OstAPIBase {
    private let userApiResourceBase = "/users"
    
    /// Initializer
    ///
    /// - Parameter userId: User id
    override init(userId: String) {
        super.init(userId: userId)
    }
    
    /// Get user entity. Make an API call and store the result in the database
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getUser(onSuccess: ((OstUser) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = userApiResourceBase + "/" + userId
        var params: [String: Any] = [:]
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: resourceURL, andParams: &params, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        get(params: params as [String : AnyObject],
            onSuccess: {(apiResponse) in
                do {
                    let entity = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(entity as! OstUser)
                }catch let error{
                    onFailure?(error as! OstError)
                }
            },
            onFailure: { (failureResponse) in
                onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
            }
        )
    }
    
    /// Activate user. Make an API call and store the result in the database
    ///
    /// - Parameters:
    ///   - params: Activate user params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func activateUser(params: [String: Any], onSuccess:((OstUser) -> Void)?, onFailure:((OstError) -> Void)?) throws {
        resourceURL = userApiResourceBase + "/" + userId + "/activate-user/"
        
        var activateUserParams = params
        // Sign API resource
        try OstAPIHelper.sign(apiResource: resourceURL, andParams: &activateUserParams, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        post(params: activateUserParams as [String: AnyObject],
             onSuccess: {(apiResponse) in
                do {
                    let entity = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(entity as! OstUser)
                }catch let error{
                    onFailure?(error as! OstError)
                }
            },
            onFailure: { (failureResponse) in
                onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
            }
        )
    }
    
    /// Get balance for user
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getBalance(onSuccess:@escaping (([String: Any]?) -> Void),
                    onFailure:@escaping (([String: Any]?) -> Void)) throws {
        resourceURL = userApiResourceBase + "/" + userId + "/balance/";
        
        var apiParams: [String : Any] = [:];
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: resourceURL, andParams: &apiParams, withUserId: self.userId)
        
        get(params: apiParams as [String : AnyObject],
            onSuccess: onSuccess,
            onFailure:onFailure);
    }
    
    /// Get transaction for user
    ///
    /// - Parameters:
    ///   - params: Fetch transaction params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getTransactions(params:[String : Any]?,
                         onSuccess:@escaping (([String: Any]?) -> Void),
                         onFailure:@escaping (([String: Any]?) -> Void)) throws {
        resourceURL = userApiResourceBase + "/" + userId + "/transactions/";
        var apiParams:[String : Any] = params ?? [:];
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: resourceURL, andParams: &apiParams, withUserId: self.userId)

        get(params: apiParams as [String : AnyObject],
            onSuccess: onSuccess,
            onFailure:onFailure);
    }
}
