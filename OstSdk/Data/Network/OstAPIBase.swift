//
//  OstAPIBase.swift
//  OstSdk
//
//  Created by aniket ayachit on 30/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire

open class OstAPIBase {
    
    var userId: String
    var resourceURL: String = ""
    
    public init(userId: String = "") {
        self.userId = userId
    }
    
    func getHeader() -> [String: String] {
        let httpHeaders = ["Content-Type": "application/x-www-form-urlencoded",
                           "User-Agent": OstConstants.OST_USER_AGENT]
        return httpHeaders
    }
    
    open var getBaseURL: String {
        return OstConstants.OST_API_BASE_URL
    }
    
    open var getResource: String {
        return resourceURL
    }

    var getSignatureKind: String {
        return OstConstants.OST_SIGNATURE_KIND
    }
    
    open func isResponseSuccess(_ response: Any?) -> Bool {
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
    
    func insetAdditionalParamsIfRequired(_ params: inout [String: Any]) {
    
        if (params["signature_kind"] == nil) {
            params["signature_kind"] = getSignatureKind
        }
        
        if (params["request_timestamp"] == nil) {
            params["request_timestamp"] = OstUtils.toString(Date.timestamp())
        }
        
        if (!userId.isEmpty) {
            do {
                if let user: OstUser = try OstUserModelRepository.sharedUser.getById(userId) as? OstUser {
                    if (params["token_id"] == nil && user.token_id != nil) {
                        params["token_id"] = user.token_id
                    }
                    if (params["user_id"] == nil) {
                        params["user_id"] = userId
                    }
                    if let currentDevice = user.getCurrentDevice() {
                        
                        if (params["api_signer_address"] == nil) {
                            params["api_signer_address"] = currentDevice.personal_sign_address!
                        }
                        
                        if (params["wallet_address"] == nil) {
                            params["wallet_address"] = currentDevice.address!
                        }
                    }
                }
            }catch {
                
            }
        }
    }
    
    func sign(_ params: inout [String: Any]) throws {
        let (signature, _) =  try OstAPISigner(userId: userId).sign(resource: getResource, params: params)
        params["signature"] = signature
    }
    
    //MARK: - HttpRequest
    public func get(params: [String: AnyObject]? = nil, success:@escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]) -> Void)) {
        
        guard OstConnectivity.isConnectedToInternet else {
            Logger.log(message: "not reachable")
            return
        }
        Logger.log(message: "reachable")
        
        let url: String = getBaseURL+getResource
        
        Logger.log(message: "url", parameterToPrint: url)
        Logger.log(message: "params", parameterToPrint: params as Any)
        
        let dataRequest = Alamofire.request(url, method: .get, parameters: params, headers: getHeader()).debugLog()
        dataRequest.responseJSON { (httpResponse) in
            let isSuccess: Bool = self.isResponseSuccess(httpResponse.result.value)
            if (httpResponse.result.isSuccess && isSuccess) {
                success(httpResponse.result.value as! [String : Any])
            }else {
                failuar(httpResponse.result.value as! [String : Any])
            }
        }
    }
    
    public func post(params: [String: AnyObject]? = nil, success:@escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]) -> Void)) {
        let url: String = getBaseURL+getResource
        
        Logger.log(message: "url", parameterToPrint: url)
        Logger.log(message: "params", parameterToPrint: params)
        
        let dataRequest = Alamofire.request(url, method: .post, parameters: params, headers: getHeader()).debugLog()
        dataRequest.responseJSON { (httpResponse) in
            let isSuccess: Bool = self.isResponseSuccess(httpResponse.result.value)
            if (httpResponse.result.isSuccess && isSuccess) {
                success(httpResponse.result.value as! [String : Any])
            }else {
                failuar((httpResponse.result.value as? [String : Any]) ?? [:])
            }
        }
    }
}
