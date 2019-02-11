//
//  OstAPIUser.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPIUser: OstAPIBase {
    
    let userApiResourceBase = "/user"
    
    override public init(userId: String) {
        super.init(userId: userId)
    }
    
    func getUser(success:@escaping ((OstUser) -> Void), failuar:@escaping ((OstError) -> Void)) throws {
        resourceURL = userApiResourceBase + "/" + userId
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)

        get(params: params as [String : AnyObject], success: { (userEntityData) in
            do {
                if let ostUser: OstUser = try OstUser.parse(userEntityData) {
                    success(ostUser)
                }else {
                    failuar(OstError.actionFailed("User Sync failed"))
                }
            }catch {
                failuar(OstError.actionFailed("User Sync failed"))
            }
            
        }) { (failuarObj) in
            failuar(OstError.actionFailed("User Sync failed"))
        }
        
    }
    
}
