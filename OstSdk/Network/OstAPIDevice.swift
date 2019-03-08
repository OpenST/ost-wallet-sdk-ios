//
//  OstAPIDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 12/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPIDevice: OstAPIBase {
    
    let userApiResourceBase: String

    /// Initializer
    ///
    /// - Parameter userId: User Id
    override init(userId: String) {
        userApiResourceBase = "/users/\(userId)/devices"
        super.init(userId: userId)
    }
    
    /// Get current device. Make an API call and store the result in the database
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getCurrentDevice(onSuccess: ((OstDevice) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        // Get current user
        guard let user: OstUser = try OstUser.getById(self.userId) else {
            throw OstError.init("n_ad_gcd_1", .userEntityNotFound)
        }
        
        // Get current device
        let currentDevice = user.getCurrentDevice()!
        try self.getDevice(deviceAddress: currentDevice.address!, onSuccess: onSuccess, onFailure: onFailure)
    }
    
    /// Get device. Make an API call and store the result in the database
    ///
    /// - Parameters:
    ///   - deviceAddress: Device address
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func getDevice(deviceAddress: String, onSuccess: ((OstDevice) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = userApiResourceBase + "/" + deviceAddress
        var params: [String: Any] = [:]

        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        get(params: params as [String : AnyObject],
            onSuccess: { (apiResponse) in
                do {
                    let entity = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(entity as! OstDevice)
                }catch let error{
                    onFailure?(error as! OstError)
                }
            },
            onFailure: { (failureResponse) in
                onFailure?(OstError.init(fromApiResponse: failureResponse!))
            }
        )
    }
    
    /// Authorize device. Make an API call and store the result in the database
    ///
    /// - Parameters:
    ///   - params: Authorize device parameters
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func authorizeDevice(params: [String: Any], onSuccess: ((OstDevice) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = userApiResourceBase + "/authorize"
        var authorizeDeviceParams: [String: Any] = params
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &authorizeDeviceParams, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        post(params: authorizeDeviceParams as [String: AnyObject],
             onSuccess: { (apiResponse) in
                do {
                    let entity = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(entity as! OstDevice)
                }catch let error{
                    onFailure?(error as! OstError)
                }
            },
            onFailure: { (failureResponse) in
                onFailure?(OstError.init(fromApiResponse: failureResponse!))
            }
        )
    }
    
    func initiateRecoverDevice(params: [String: Any], onSuccess: ((OstDevice) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = userApiResourceBase + "/initiate-recovery"
        
        var revokeDeviceParams: [String: Any] = params
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &revokeDeviceParams, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        post(params: revokeDeviceParams as [String: AnyObject],
             onSuccess: { (apiResponse) in
                do {
                    let entity = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(entity as! OstDevice)
                }catch let error{
                    onFailure?(error as! OstError)
                }
        }) { (failureResponse) in
            onFailure?(OstError.init(fromApiResponse: failureResponse!))
        }
    }
}
