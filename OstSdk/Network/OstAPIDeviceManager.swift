//
//  OstAPIDeviceManager.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

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
                onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
            }
        )
    }
}
