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
    override public init(userId: String) {
        deviceManagerApiResourceBase = "/users/\(userId)"
        super.init(userId: userId)
    }
    
    func getDeviceManager(onSuccess: ((OstDeviceManager) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
     
        resourceURL = deviceManagerApiResourceBase + "/" + "device-managers"
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        
        get(params: params as [String : AnyObject], onSuccess: { (apiResponse) in
            do {
                let entity = try self.parseEntity(apiResponse: apiResponse)
                onSuccess?(entity as! OstDeviceManager)
            }catch let error{
                onFailure?(error as! OstError)
            }
        }) { (failuarObj) in
            onFailure?(OstError.actionFailed("device-manager Sync failed"))
        }
    }
}
