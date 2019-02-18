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
    
    var requestTimeout: Int  = 6
    var dataRequest: DataRequest? = nil
    let manager: SessionManager
    
    public init(userId: String = "") {
        self.userId = userId
        
        self.manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = TimeInterval(requestTimeout)
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
    
        if (params["api_signature_kind"] == nil) {
            params["api_signature_kind"] = getSignatureKind
        }
        
        if (params["api_request_timestamp"] == nil) {
            params["api_request_timestamp"] = OstUtils.toString(Date.timestamp())
        }
        
        if (!userId.isEmpty) {
            do {
                if let user: OstUser = try OstUser.getById(userId) {
                    if (params["token_id"] == nil && user.tokenId != nil) {
                        params["token_id"] = user.tokenId
                    }
                    if (params["user_id"] == nil) {
                        params["user_id"] = userId
                    }
                    if let currentDevice = user.getCurrentDevice() {
                        
                        if (params["api_key"] == nil) {
                            params["api_key"] = currentDevice.address! + "." + currentDevice.api_signer_address!
                        }
                    }
                }
            }catch {
                
            }
        }
    }
    
    func sign(_ params: inout [String: Any]) throws {
        let (signature, _) =  try OstAPISigner(userId: userId).sign(resource: getResource, params: params)
        params["api_signature"] = signature
    }
    
    //MARK: - HttpRequest
    open func get(params: [String: AnyObject]? = nil, success:@escaping (([String: Any]?) -> Void), onFailure:@escaping (([String: Any]?) -> Void)) {
        
        guard OstConnectivity.isConnectedToInternet else {
            Logger.log(message: "not reachable")
            return
        }
        Logger.log(message: "reachable")
        
        let url: String = getBaseURL+getResource
        
        Logger.log(message: "url", parameterToPrint: url)
        Logger.log(message: "params", parameterToPrint: params as Any)
        
        dataRequest = manager.request(url, method: .get, parameters: params, headers: getHeader()).debugLog()
        dataRequest!.responseJSON { (httpResponse) in
            
            Logger.log(message: httpResponse.response?.url?.relativePath ?? "", parameterToPrint: httpResponse.result.value)
            
            let isSuccess: Bool = self.isResponseSuccess(httpResponse.result.value)
            if (httpResponse.result.isSuccess && isSuccess) {
                success((httpResponse.result.value as? [String : Any])?["data"] as? [String: Any])
            }else {
                onFailure(httpResponse.result.value as? [String : Any])
            }
        }
    }
    
    open func post(params: [String: AnyObject]? = nil, success:@escaping (([String: Any]?) -> Void), onFailure:@escaping (([String: Any]?) -> Void)) {
        let url: String = getBaseURL+getResource
        
        Logger.log(message: "url", parameterToPrint: url)
        Logger.log(message: "params", parameterToPrint: params)
        
        dataRequest = manager.request(url, method: .post, parameters: params, headers: getHeader()).debugLog()
        dataRequest!.responseJSON { (httpResponse) in
            
            Logger.log(message: httpResponse.response?.url?.relativePath ?? "", parameterToPrint: httpResponse.result.value)
            
            let isSuccess: Bool = self.isResponseSuccess(httpResponse.result.value)
            if (httpResponse.result.isSuccess && isSuccess) {
                success(httpResponse.result.value as? [String : Any])
            }else {
                onFailure((httpResponse.result.value as? [String : Any]))
            }
        }
    }
    
    //MARK: - parse entites
    func parseEntity(apiResponse: [String: Any?]?) throws -> OstBaseEntity {
        if (apiResponse != nil) {
            do {
                if let entity = try OstSdk.parseApiResponse(apiResponse!) {
                    return entity
                }else {
                    throw OstError.actionFailed("Entity parsing failed.")
                }
            }catch {
                throw OstError.actionFailed("Entity parsing failed.")
            }
        }else {
            throw OstError.actionFailed("Entity Sync failed.")
        }
    }
}
