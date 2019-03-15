/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAPIDeviceManager: OstAPIBase {
    
    let deviceManagerApiResourceBase: String
    
    
    /// Initializer
    ///
    /// - Parameter userId: User Id
    override init(userId: String) {
        deviceManagerApiResourceBase = "/users/\(userId)"
        super.init(userId: userId)
    }
    
    /// Get device manager. Make an API call and store the result in the database
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getDeviceManager(onSuccess: ((OstDeviceManager) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = deviceManagerApiResourceBase + "/" + "device-managers"
        var params: [String: Any] = [:]

        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        get(params: params as [String : AnyObject],
            onSuccess: { (apiResponse) in
                do {
                    let entity = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(entity as! OstDeviceManager)
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
