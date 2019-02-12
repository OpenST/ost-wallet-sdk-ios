//
//  OstTokenHolderAPI.swift
//  OstSdk
//
//  Created by aniket ayachit on 06/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPITokenHolder: OstAPIBase {
    override init(userId: String) {
        super.init(userId: userId)
    }
    
    override var getResource: String {
        return "/users/\(userId)/token-holders/"
    }
    
    func deployTokeHolder(params: [String: Any], success:@escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]) -> Void)) throws {
        var params = params
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        post(params: params as [String : AnyObject], success: success as! (([String : Any]?) -> Void), failuar: failuar as! (([String : Any]?) -> Void))
    }
}
