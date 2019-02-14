//
//  OstAPIUser.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPIUser: OstAPIBase {
    
    let userApiResourceBase = "/users"
    
    override public init(userId: String) {
        super.init(userId: userId)
    }
    
    func getUser(success: ((OstUser) -> Void)?, failuar: ((OstError) -> Void)?) throws {
        resourceURL = userApiResourceBase + "/" + userId
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)

        get(params: params as [String : AnyObject], success: { (apiResponse) in
            do {
                let entity = try self.parseEntity(apiResponse: apiResponse)
                success?(entity as! OstUser)
            }catch let error{
                failuar?(error as! OstError)
            }
        }) { (failuarObj) in
            failuar?(OstError.actionFailed("User Sync failed."))
        }
    }
    
    func activateUser(params: [String: Any], success:((OstUser) -> Void)?, failuar:((OstError) -> Void)?) throws {
        resourceURL = userApiResourceBase + "/\(userId)/activate-use/"
        
        var loParams = params
        insetAdditionalParamsIfRequired(&loParams)
        try sign(&loParams)
        
        post(params: params as [String: AnyObject], success: { (apiResponse) in
            do {
                let entity = try self.parseEntity(apiResponse: apiResponse)
                success?(entity as! OstUser)
            }catch let error{
                failuar?(error as! OstError)
            }
        }) { (failuarObj) in
            failuar?(OstError.actionFailed("activate user failed."))
        }
    }
}
