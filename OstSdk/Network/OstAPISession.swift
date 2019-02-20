//
//  OstAPISession.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPISession: OstAPIBase {
    
    let sessionApiResourceBase: String
    override public init(userId: String) {
        sessionApiResourceBase = "/users/\(userId)/sessions"
        super.init(userId: userId)
    }
    
    func getSession(sessionAddress: String, onSuccess: ((OstSession) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
    
        resourceURL = sessionApiResourceBase + "/" + sessionAddress
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        
        get(params: params as [String : AnyObject], onSuccess: { (apiResponse) in
            do {
                let entity = try self.parseEntity(apiResponse: apiResponse)
                onSuccess?(entity as! OstSession)
            }catch let error{
                onFailure?(error as! OstError)
            }
        }) { (failuarObj) in
            onFailure?(OstError.actionFailed("Session Sync failed"))
        }
    }
    
    func authorizeSession(params: [String: Any], onSuccess: ((OstSession) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = sessionApiResourceBase + "/authorize"
        
        var loParams: [String: Any] = params
        insetAdditionalParamsIfRequired(&loParams)
        try sign(&loParams)
        
        post(params: loParams as [String : AnyObject], onSuccess: { (apiResponse) in
            do {
                let entity = try self.parseEntity(apiResponse: apiResponse)
                onSuccess?(entity as! OstSession)
            }catch let error{
                onFailure?(error as! OstError)
            }
        }) { (failuarObj) in
            onFailure?(OstError.actionFailed("Session Sync failed"))
        }
    }
}
