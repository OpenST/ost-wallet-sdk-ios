//
//  OstAPIChain.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPIChain: OstAPIBase {
    
    let chainApiResourceBase: String
    let chainId: String
    
    init(chainId: String, userId: String) {
        self.chainApiResourceBase = "/chains/"
        self.chainId = chainId
        super.init(userId: userId)
    }
    
    func getChain(success: (([String: Any]) -> Void)?, failuar: ((OstError) -> Void)?) throws {
        
        resourceURL = chainApiResourceBase + "/" + self.chainId
        
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        
        get(params: params as [String : AnyObject], success: { (apiResponse) in
            let resultType = apiResponse!["result_type"] as! String
            if (resultType == "chain") {
                success?(apiResponse![resultType] as! [String: Any])
            }else {
                failuar?(OstError.actionFailed("getting salt failed"))
            }
        }) { (failuarObj) in
            failuar?(OstError.actionFailed("device-manager Sync failed"))
        }
    }
}
