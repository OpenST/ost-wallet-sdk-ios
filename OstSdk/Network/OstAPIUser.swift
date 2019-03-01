//
//  OstAPIUser.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPIUser: OstAPIBase {
    let userApiResourceBase = "/users"
    
    /// Initializer
    ///
    /// - Parameter userId: User id
    override public init(userId: String) {
        super.init(userId: userId)
    }
    
    // TODO: remove public from this function
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
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
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
                onFailure?(OstError.init(fromApiResponse: failureResponse!))
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
        try OstAPIHelper.sign(apiResource: getResource, andParams: &activateUserParams, withUserId: self.userId)
        
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
                onFailure?(OstError.init(fromApiResponse: failureResponse!))
            }
        )
    }
}
