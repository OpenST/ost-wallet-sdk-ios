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
    
    func getDevice(success: ((OstDevice) -> Void)?, failuar: ((OstError) -> Void)?) throws {
        
        let user: OstUser! = try! OstUserModelRepository.sharedUser.getById(self.userId) as! OstUser
        let currentDevice = user.getCurrentDevice()!
        resourceURL = userApiResourceBase + "/" + currentDevice.address!
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        
        get(params: params as [String : AnyObject], success: { (apiResponse) in
            do {
                let entity = try self.parseEntity(apiResponse: apiResponse)
                success?(entity as! OstDevice)
            }catch let error{
                failuar?(error as! OstError)
            }
        }) { (failuarObj) in
            failuar?(OstError.actionFailed("device Sync failed"))
        }   
    }
}
