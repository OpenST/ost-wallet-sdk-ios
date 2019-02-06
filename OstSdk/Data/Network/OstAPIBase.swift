//
//  OstAPIBase.swift
//  OstSdk
//
//  Created by aniket ayachit on 30/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire

public class OstAPIBase {
    
    static func isResponseSuccess(_ response: Any?) -> Bool {
        if (response == nil) { return false }
        if let successValue = (response as? [String: Any])?["success"] {
            if successValue is Int {
                return (successValue as! Int) > 0
            }else if successValue is String {
                let successStringValue = successValue as! String
                if (successStringValue  == "true" || successStringValue != "0") {
                    return true
                }
            }
        }
        return false
    }
    
    public init() { }
    
    func getHeader() -> [String: String] {
        let httpHeaders = ["Content-Type": "application/x-www-form-urlencoded",
                           "User-Agent": getUserAgent()]
        return httpHeaders
    }
    
    func getUserAgent() -> String {
        return OstConstants.OST_USER_AGENT
    }
    
    var getBaseURL: String {
        return OstConstants.OST_API_BASE_URL
    }
    
    var getResource: String {
        fatalError("resource not override")
    }

    var getSignatureKind: String {
        return OstConstants.OST_SIGNATURE_KIND
    }
    
    func insetAdditionalParamsIfRequired(_ params: inout [String: Any?]) {
        if (params["signature_kind"] == nil) {
            params["signature_kind"] = getSignatureKind
        }
        
        if (params["request_timestamp"] == nil) {
            params["request_timestamp"] = OstUtils.toString(Date.timestamp())
        }
        
        if (params["user_id"] == nil) {
            params["user_id"] = OstUser.currentDevice!.user_id!
        }
        
        if (params["token_id"] == nil) {
            params["token_id"] = OstUser.tokenId
        }
       
        if (params["api_signer_address"] == nil) {
            params["api_signer_address"] = OstUser.currentDevice!.personal_sign_address!
        }
        
        if (params["wallet_address"] == nil) {
            params["wallet_address"] = OstUser.currentDevice!.address!
        }
    }
    
    //MARK: - HttpRequest
    func get(params: [String: AnyObject], success:@escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]) -> Void)) {
        
        let url: String = getBaseURL+getResource
        
        Logger().DLog(message: "url", parameterToPrit: url)
        Logger().DLog(message: "params", parameterToPrit: params)
        
        let dataRequest = Alamofire.request(url, method: .get, parameters: params, headers: getHeader()).debugLog()
        dataRequest.responseJSON { (httpResponse) in
            let isSuccess: Bool = OstAPIBase.isResponseSuccess(httpResponse.result.value)
            if (httpResponse.result.isSuccess && isSuccess) {
                success(httpResponse.result.value as! [String : Any])
            }else {
                failuar(httpResponse.result.value as! [String : Any])
            }
        }
    }
}
