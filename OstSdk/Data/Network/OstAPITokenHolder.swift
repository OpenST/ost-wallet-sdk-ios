//
//  OstTokenHolderAPI.swift
//  OstSdk
//
//  Created by aniket ayachit on 06/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPITokenHolder: OstAPIBase {
    
    let apiTokenHolderResourceBase: String
    override init(userId: String) {
        apiTokenHolderResourceBase = "/users/\(userId)/activate-user"
        super.init(userId: userId)
    }

    func activateUser(params: [String: Any], success:((OstUser) -> Void)?, failuar:((OstError) -> Void)?) throws {
        
        resourceURL = apiTokenHolderResourceBase + "/"
        
        var params = params
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        
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
