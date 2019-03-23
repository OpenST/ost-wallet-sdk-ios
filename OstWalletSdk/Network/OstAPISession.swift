/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAPISession: OstAPIBase {
    private static let syncDeleteSessionsQueue = DispatchQueue(label: "com.ost.SyncDeleteSessionQueue", qos: .background)
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
    func getSession(sessionAddress: String,
                    onSuccess: ((OstSession) -> Void)?,
                    onFailure: ((OstError) -> Void)?) throws {
        
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
                let apiError = OstApiError.init(fromApiResponse: failureResponse!)
                if apiError.isNotFound() {
                    self.deleteSession(sessionAddress)
                }
                onFailure?(apiError)
            }
        )
    }
    
    /// Delete sessions from keymanager
    ///
    /// - Parameter address: Session address to delete
    private func deleteSession(_ address: String) {
        let sessionQueue = DispatchQueue(label: "deleteSessionQueue", qos: .background)
        sessionQueue.async {
            self.getSyncQueueForDeleteSessions().sync {
                let keyManager = OstKeyManager(userId: self.userId)
                try? keyManager.deleteSessionKey(sessionAddress: address)
            }
        }
    }
    
    /// Get queue for delete session
    ///
    /// - Returns: DispatchQueue
    private func getSyncQueueForDeleteSessions() -> DispatchQueue {
        return OstAPISession.syncDeleteSessionsQueue
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
                onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
            }
        )
    }
}
