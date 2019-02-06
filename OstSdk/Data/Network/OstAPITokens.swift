//
//  OstTokensAPI.swift
//  OstSdk
//
//  Created by aniket ayachit on 05/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire

class OstAPITokens: OstAPIBase {
    
    override var getResource: String {
        return "/tokens/"
    }
    
    public func getToken(success:@escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]) -> Void)) throws {
        var params: [String: Any] = [:]
        insetAdditionalParamsIfRequired(&params)
        try sign(&params)
        get(params: params as [String : AnyObject], success: success, failuar: failuar)
    }
}
