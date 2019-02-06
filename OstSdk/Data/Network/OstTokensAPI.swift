//
//  OstTokensAPI.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire

class OstTokensAPI: OstAPIBase {

    override var getResource: String {
        return "/tokens/"
    }
    
    public func getToken(success:@escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]) -> Void)) throws {
        var params: [String: Any?] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        get(params: params as [String : AnyObject], success: success, failuar: failuar)
    }
    
    func sign(_ params: inout [String: Any?]) throws {
        let (signature, _) =  try OstAPISigner(userId: OstUser.currentDevice!.user_id!).sign(resource: getResource, params: params)
        params["signature"] = signature
    }
}
