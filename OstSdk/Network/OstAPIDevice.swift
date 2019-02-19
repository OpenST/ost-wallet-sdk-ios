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

    override public init(userId: String) {
        userApiResourceBase = "/users/\(userId)/devices"
        super.init(userId: userId)
    }
    
    func getCurrentDevice(onSuccess: ((OstDevice) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        
        let user: OstUser! = try OstUser.getById(self.userId)
        let currentDevice = user.getCurrentDevice()!
        resourceURL = userApiResourceBase + "/" + currentDevice.address!
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        
        get(params: params as [String : AnyObject], onSuccess: { (apiResponse) in
            do {
                let entity = try self.parseEntity(apiResponse: apiResponse)
                onSuccess?(entity as! OstDevice)
            }catch let error{
                onFailure?(error as! OstError)
            }
        }) { (failuarObj) in
            onFailure?(OstError.actionFailed("device Sync failed."))
        }   
    }
    
    func authorizeDevice(params: [String: Any], onSuccess: ((OstDevice) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = userApiResourceBase + "/authorize"
        
        var loParams: [String: Any] = params
        insetAdditionalParamsIfRequired(&loParams)
        try sign(&loParams)
        
        post(params: loParams as [String: AnyObject], onSuccess: { (apiResponse) in
            do {
                let entity = try self.parseEntity(apiResponse: apiResponse)
                onSuccess?(entity as! OstDevice)
            }catch let error{
                onFailure?(error as! OstError)
            }
        }) { (failuarObj) in
             onFailure?(OstError.actionFailed("device authorize failed."))
        }
    }
}
