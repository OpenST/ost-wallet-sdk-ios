/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAPIDevice: OstAPIBase {
    
    let deviceApiResourceBase: String

    /// Initializer
    ///
    /// - Parameter userId: User Id
    override init(userId: String) {
        deviceApiResourceBase = "/users/\(userId)/devices"
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
      print("debug print :: getting user from database. userId: \(self.userId)");
        guard let user: OstUser = try OstUser.getById(self.userId) else {
          print("debug print :: user not found");
            throw OstError("n_ad_gcd_1", .userEntityNotFound)
        }
      
      print("debug print :: user found in db. user: \(user.data as AnyObject)");
      
        // Get current device
      print("debug print :: getting current device from user obj");
        guard let currentDevice = user.getCurrentDevice() else {
            throw OstError("n_ad_gcd_1", .deviceNotSet)
        }
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
        resourceURL = deviceApiResourceBase + "/" + deviceAddress
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
                onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
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
        resourceURL = deviceApiResourceBase + "/authorize"
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
                onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
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
    func revokeDevice(params: [String: Any],
                      onSuccess: ((OstDevice) -> Void)?,
                      onFailure: ((OstError) -> Void)?) throws {
        
        resourceURL = deviceApiResourceBase + "/revoke"
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
        },
             onFailure: { (failureResponse) in
                onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
        }
        )
    }
    
    /// Initiate recover device
    ///
    /// - Parameters:
    ///   - params: Initiate recover device params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func initiateRecoverDevice(params: [String: Any],
                               onSuccess: ((OstDevice) -> Void)?,
                               onFailure: ((OstError) -> Void)?) throws {
        
        resourceURL = deviceApiResourceBase + "/initiate-recovery"
        
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
            onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
        }
    }
    
    /// Abort recover device
    ///
    /// - Parameters:
    ///   - params: Abort recover device params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    /// - Throws: OSTError
    func abortRecoverDevice(params: [String: Any],
                            onSuccess: ((OstDevice) -> Void)?,
                            onFailure: ((OstError) -> Void)?) throws {
        
        resourceURL = deviceApiResourceBase + "/abort-recovery"
        
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
            onFailure?(OstApiError.init(fromApiResponse: failureResponse!))
        }
    }
    
    /// Get pending recovery for user
    ///
    /// - Parameters:
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    func getPendingRecovery(onSuccess: (([OstDevice]) -> Void)?,
                            onFailure: ((OstError) -> Void)?) throws {
        
        resourceURL = deviceApiResourceBase + "/pending-recovery/"
        
        var pendingRecoveryDeviceParams: [String: Any] = [:]
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &pendingRecoveryDeviceParams, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        get(params: pendingRecoveryDeviceParams as [String: AnyObject],
            onSuccess: { (apiResponse) in
                do {
                    let entities = try OstAPIHelper.syncEntitiesWithAPIResponse(apiResponse: apiResponse)
                    onSuccess?(entities as! [OstDevice])
                }catch let error{
                    onFailure?(error as! OstError)
                }
        }) { (failureResponse) in
            onFailure?(OstError(fromApiResponse: failureResponse!))
        }
    }
    
    /// Get pending recovery from server
    ///
    /// - Parameters:
    ///   - params: Pending recovery params
    ///   - onSuccess: Success params
    ///   - onFailure: Failure params
    /// - Throws: OstError
    func getJsonPendingRecovery(params:[String : Any]?,
                            onSuccess:@escaping (([String: Any]?) -> Void),
                            onFailure:@escaping (([String: Any]?) -> Void)) throws {
        resourceURL = deviceApiResourceBase + "/pending-recovery/";
        var apiParams:[String : Any] = params ?? [:];
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: resourceURL, andParams: &apiParams, withUserId: self.userId)
        
        get(params: apiParams as [String : AnyObject],
            onSuccess: onSuccess,
            onFailure:onFailure);
    }
    
    /// Get device list from server
    ///
    /// - Parameters:
    ///   - params: Device list params
    ///   - onSuccess: Success params
    ///   - onFailure: Failure params
    /// - Throws: OstError
    func getDeviceList(params:[String : Any]?,
                       onSuccess:@escaping (([String: Any]?) -> Void),
                       onFailure:@escaping (([String: Any]?) -> Void)) throws {
        
        resourceURL = deviceApiResourceBase
        var apiParams:[String : Any] = params ?? [:];
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: resourceURL, andParams: &apiParams, withUserId: self.userId)
        
        get(params: apiParams as [String : AnyObject],
            onSuccess: onSuccess,
            onFailure:onFailure);
    }
    
    /// Get current device from server
    ///
    /// - Parameters:
    ///   - onSuccess: Success params
    ///   - onFailure: Failure params
    /// - Throws: OstError
    func getCurrentDeviceJsonApi(onSuccess:@escaping (([String: Any]?) -> Void),
                                 onFailure:@escaping (([String: Any]?) -> Void)) throws {
        
        let user = try OstUser.getById(self.userId)
        if let currentDevice = user?.getCurrentDevice() {
            resourceURL = deviceApiResourceBase + "/" + currentDevice.address!
        }
        
        var params: [String: Any] = [:]
        
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)
        
        // Make an API call and store the data in database.
        get(params: params as [String : AnyObject],
            onSuccess: { (apiResponse) in
                do {
                    _ = try OstAPIHelper.syncEntityWithAPIResponse(apiResponse: apiResponse)
                    onSuccess(apiResponse)
                }catch let error{
                    onFailure((error as! OstError).errorInfo)
                }
        },
            onFailure: onFailure)
    }
}
