//
//  OstAPISession.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPISession: OstAPIBase {
    
    private let sessionApiResourceBase: String
    
    /// Initializer
    ///
    /// - Parameter userId: User id
    override init(userId: String) {
        sessionApiResourceBase = "/users/\(userId)/sessions"
        super.init(userId: userId)
    }
    
    /// Get session. Make an API call and store the result in the database
    ///
    /// - Parameters:
    ///   - sessionAddress: Session address
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getSession(sessionAddress: String, onSuccess: ((OstSession) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = sessionApiResourceBase + "/" + sessionAddress
        var params: [String: Any] = [:]

        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        get(params: params as [String : AnyObject],
            onSuccess: { (apiResponse) in
                do {
                    let entity = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(entity as! OstSession)
                } catch let error{
                    onFailure?(error as! OstError)
                }
            },
            onFailure: { (failureResponse) in
                onFailure?(OstError.init(fromApiResponse: failureResponse!))
            }
        )
    }
    
    /// Authorize session. Make an API call and store the result in the database
    ///
    /// - Parameters:
    ///   - params: Authorize session params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func authorizeSession(params: [String: Any], onSuccess: ((OstSession) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = sessionApiResourceBase + "/authorize"
        var authorizeSessionParams: [String: Any] = params

        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &authorizeSessionParams, withUserId: self.userId)

        // Make an API call and store the data in database.
        post(params: authorizeSessionParams as [String : AnyObject],
             onSuccess: { (apiResponse) in
                do {
                    let entity = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(entity as! OstSession)
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
