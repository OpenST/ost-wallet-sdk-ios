//
//  OstAPISalt.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPISalt: OstAPIBase {
    
    let apiSaltResourceBase: String
    
    override init(userId: String) {
        apiSaltResourceBase = "/users/\(userId)/salts"
        super.init(userId: userId)
    }
    
    func getRecoverykeySalt(success: (([String: Any]) -> Void)?, failuar: ((OstError) -> Void)?) throws {
        
        resourceURL = apiSaltResourceBase + "/"
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        
        get(params: params as [String: AnyObject], success: { (apiResponse) in
            
            let resultType = apiResponse!["result_type"] as! String
            if (resultType == "salt") {
                success?(apiResponse![resultType] as! [String: Any])
            }else {
                failuar?(OstError.actionFailed("getting salt failed"))
            }
            
        }) { (failuareResponse) in
            failuar?(OstError.actionFailed("getting salt failed"))
        }
    }
}
