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
    
    func getSession(sessionAddress: String, success: ((OstSession) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
    
        resourceURL = sessionApiResourceBase + "/" + sessionAddress
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        
        get(params: params as [String : AnyObject], success: { (apiResponse) in
            do {
                let entity = try self.parseEntity(apiResponse: apiResponse)
                success?(entity as! OstSession)
            }catch let error{
                onFailure?(error as! OstError)
            }
        }) { (failuarObj) in
            onFailure?(OstError.actionFailed("Session Sync failed"))
        }
    }
}
