//
//  OstAPIBase.swift
//  OstSdk
//
//  Created by aniket ayachit on 30/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire

// TODO: Remove the Open keyword from this class.
/// Base class for all API calls
open class OstAPIBase {
    /// URL endpoint
    static var baseURL: String = "";
    
    /// Class function to set API endpoint
    class func setAPIEndpoint(_ apiEndpoint: String) {
        baseURL = apiEndpoint
    }
    
    /// User Id associated with the API requests
    var userId: String
    
    /// Relative URL that can be appended with base URL endpoint
    var resourceURL: String = ""
    
    /// Request timeout duration in seconds
    var requestTimeout: Int  = OstConstants.OST_REQUEST_TIMEOUT_DURATION
    
    /// Request data
    var dataRequest: DataRequest? = nil
    
    /// Session manager
    let manager: SessionManager
    
    /// Initializer
    ///
    /// - Parameter userId: User Id associated with the API requests
    public init(userId: String) {
        self.userId = userId
        self.manager = Alamofire.SessionManager.default
        manager.session.configuration.timeoutIntervalForRequest = TimeInterval(requestTimeout)
    }
    
    /// Get HTTP request header params
    ///
    /// - Returns: HTTP header params
    func getHeader() -> [String: String] {
        let httpHeaders = ["Content-Type": OstConstants.OST_CONTENT_TYPE,
                           "User-Agent": OstConstants.OST_USER_AGENT]
        return httpHeaders
    }
    
    // TODO: Remove this method once we remove open keywords.
    /// Get the base URL string
    open var getBaseURL: String {
        return OstAPIBase.baseURL
    }
    
    // TODO: Remove open keyword
    /// Get the relative resource URL string
    open var getResource: String {
        return resourceURL
    }
    
    var url: String {
        return "\(OstAPIBase.baseURL)\(getResource)"
    }
    
    //MARK: - HttpRequest
    
    /// Send request
    ///
    /// - Parameters:
    ///   - method: HTTP method
    ///   - params: Request params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    func request(method: HTTPMethod,
                 params: [String: AnyObject]? = nil,
                 onSuccess:@escaping (([String: Any]?) -> Void),
                 onFailure:@escaping (([String: Any]?) -> Void)) {
        // Check if the internet connectivity is available, if not then dont send request
        guard OstConnectivity.isConnectedToInternet else {
            Logger.log(message: "System appears offline. Please check your internet connectivity")
            let noInternetResponse = OstAPIErrorHandler.getNoInternetConnectivityResponse()
            onFailure(noInternetResponse)
            return
        }
        
        Logger.log(message: "url", parameterToPrint: url)
        Logger.log(message: "params", parameterToPrint: params as Any)
        
        // TODO: remove the debug logs
        dataRequest = manager.request(url, method: method, parameters: params, headers: getHeader()).debugLog()
        
        // Status code in 200 range will be considered as correct response
//        dataRequest?.validate(statusCode: 200..<300)
        
        dataRequest!.responseJSON { (httpResponse) in
            Logger.log(message: "httpResponse.relativePath", parameterToPrint: httpResponse.response?.url?.relativePath);
            Logger.log(message: "httpResponse.result.value", parameterToPrint: httpResponse.result.value);
            
            let isSuccess: Bool = self.isResponseSuccess(httpResponse.result.value)
            if (httpResponse.result.isSuccess && isSuccess) {
                let responseEntity = ((httpResponse.result.value as? [String : Any?])?["data"] ?? httpResponse.result.value) as? [String : Any]
                onSuccess(responseEntity)
            }else {
                let failureResponse = OstAPIErrorHandler.getErrorResponse(httpResponse);
                onFailure(failureResponse)
            }
        }
    }
    
    // TODO: Remove open keyword
    /// Performs HTTP Get
    ///
    /// - Parameters:
    ///   - params: Request params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    open func get(params: [String: AnyObject]? = nil,
                  onSuccess:@escaping (([String: Any]?) -> Void),
                  onFailure:@escaping (([String: Any]?) -> Void)) {
        self.request(method: .get,
                     params: params,
                     onSuccess: onSuccess,
                     onFailure: onFailure)
    }
    
    // TODO: Remove open keyword
    /// Performs HTTP post
    ///
    /// - Parameters:
    ///   - params: Request params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    open func post(params: [String: AnyObject]? = nil,
                   onSuccess:@escaping (([String: Any]?) -> Void),
                   onFailure:@escaping (([String: Any]?) -> Void)) {
        self.request(method: .post,
                     params: params,
                     onSuccess: onSuccess,
                     onFailure: onFailure)
    }

    // TODO: Remove open keyword
    /// Check if the response is successful
    ///
    /// - Parameter response: API response object
    /// - Returns: `true` if successful otherwise false
    open func isResponseSuccess(_ response: Any?) -> Bool {
        if (response == nil) { return false }
        if let successValue = (response as? [String: Any])?["success"] {
            if successValue is Int {
                return (successValue as! Int) > 0
            }else if successValue is String {
                let successStringValue = successValue as! String
                if (successStringValue  == "true" || successStringValue == "1") {
                    return true
                }
            }
        }
        return false
    }
}

