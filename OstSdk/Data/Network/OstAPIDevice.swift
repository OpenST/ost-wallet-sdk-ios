//
//  OstAPIDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 12/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPIDevice: OstAPIBase {
    
    var userApiResourceBase: String
    override public init(userId: String) {
        userApiResourceBase = "/users/\(userId)/devices"
        super.init(userId: userId)
    }
    
    func getDevice(success:@escaping ((OstDevice) -> Void), failuar:@escaping ((OstError) -> Void)) throws {
        
        let user: OstUser! = try OstUserModelRepository.sharedUser.getById(self.userId) as! OstUser
        let currentDevice = user.getCurrentDevice()!
        resourceURL = userApiResourceBase + "/" + currentDevice.address!
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        
        get(params: params as [String : AnyObject], success: { (deviceEntityData) in
            do {
                let resultType = deviceEntityData?["result_type"] as? String ?? ""
                if (resultType == "device") {
                    let deviceEntity = deviceEntityData![resultType] as! [String: Any]
                    
                    if let ostDevice: OstDevice = try OstDevice.parse(deviceEntity) {
                        success(ostDevice)
                    }else {
                        failuar(OstError.actionFailed("User Sync failed"))
                    }
                }else {
                    failuar(OstError.actionFailed("User failed due to unexpected data format."))
                }
            }catch {
                failuar(OstError.actionFailed("User Sync failed"))
            }
            
        }) { (failuarObj) in
            failuar(OstError.actionFailed("User Sync failed"))
        }
        
    }
    
}
