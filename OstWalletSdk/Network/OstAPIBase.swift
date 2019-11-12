/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import Alamofire
import TrustKit

/// Base class for all API calls
class OstAPIBase {
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
    var requestTimeout: Int  = OstConfig.getRequestTimeoutDuration()
    
    /// Request data
    var dataRequest: DataRequest? = nil
    
    /// Session manager
    let manager: SessionManager
    
    ///Trust kit for pinning
    let trustKit: TrustKit
    
    /// Initializer
    ///
    /// - Parameter userId: User Id associated with the API requests
    init(userId: String) {
        self.userId = userId
        self.manager = Alamofire.SessionManager()
        self.trustKit = OstAPIBase.getTrustKit()

        manager.session.configuration.timeoutIntervalForRequest = TimeInterval(requestTimeout)
    }
    
    /// Get HTTP request header params
    ///
    /// - Returns: HTTP header params
    private func getHeader() -> [String: String] {
        let httpHeaders = ["Content-Type": OstConstants.OST_CONTENT_TYPE,
                           "User-Agent": OstConstants.OST_USER_AGENT]
        return httpHeaders
    }
    
    /// Get the base URL string
    var getBaseURL: String {
        return OstAPIBase.baseURL
    }
    
    /// Get the relative resource URL string
    var getResource: String {
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
             // Logger.log(message: "System appears offline. Please check your internet connectivity")
            let noInternetResponse = OstAPIErrorHandler.getNoInternetConnectivityResponse()
            onFailure(noInternetResponse)
            return
        }
        
        let delegate: SessionDelegate = manager.delegate
        delegate.sessionDidReceiveChallengeWithCompletion = {[weak self] (session, authenticationChallenge, completion:@escaping ((URLSession.AuthChallengeDisposition, URLCredential?) -> Void)) in
            
            if let strongSelf = self {
                let pinningValidator: TSKPinningValidator = strongSelf.trustKit.pinningValidator
                if !pinningValidator.handle(authenticationChallenge, completionHandler: completion) {
                    completion(.performDefaultHandling, nil);
                }
            }
        }
        
        dataRequest = manager.request(url, method: method, parameters: params, headers: getHeader())
        dataRequest!.responseJSON { (httpResponse) in
            Logger.log(message: "Response:- \(method.rawValue):- \(httpResponse.response?.url?.relativePath ?? "")", parameterToPrint: httpResponse.result.value);
            let isSuccess: Bool = self.isResponseSuccess(httpResponse.result.value)
            if (httpResponse.result.isSuccess && isSuccess) {
                let responseEntity = ((httpResponse.result.value as? [String : Any?])?["data"] ?? httpResponse.result.value) as? [String : Any]
                onSuccess(responseEntity)
                self.manager.session.configuration.urlCache?.removeAllCachedResponses()
            }else {
                let failureResponse = OstAPIErrorHandler.getErrorResponse(httpResponse);
                self.processIfUserUnauthorized(failureResponse: failureResponse)
                onFailure(failureResponse)
            }
        }
    }
    
    /// Verify whether user is unauthorized or not. If yes delete device key and api key
    ///
    /// - Parameter failureResponse: Http api response
    private func processIfUserUnauthorized(failureResponse: [String: Any]) {
        let apiError = OstApiError(fromApiResponse: failureResponse)
            if apiError.isApiSignerUnauthorized() {
                if let user = try? OstUser.getById(self.userId),
                    let device = user?.getCurrentDevice() {
                    if !device.isStatusCreated {
                        try? OstKeyManagerGateway
                            .getOstKeyManager(userId: self.userId)
                            .clearUserDeviceInfo()
                    }
                }
            }
    }
    /// Performs HTTP Get
    ///
    /// - Parameters:
    ///   - params: Request params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    func get(params: [String: AnyObject]? = nil,
             onSuccess:@escaping (([String: Any]?) -> Void),
             onFailure:@escaping (([String: Any]?) -> Void)) {
        self.request(method: .get,
                     params: params,
                     onSuccess: onSuccess,
                     onFailure: onFailure)
    }
    
    /// Performs HTTP post
    ///
    /// - Parameters:
    ///   - params: Request params
    ///   - onSuccess: Success callback
    ///   - onFailure: Failure callback
    func post(params: [String: AnyObject]? = nil,
              onSuccess:@escaping (([String: Any]?) -> Void),
              onFailure:@escaping (([String: Any]?) -> Void)) {
        self.request(method: .post,
                     params: params,
                     onSuccess: onSuccess,
                     onFailure: onFailure)
    }
    
    /// Check if the response is successful
    ///
    /// - Parameter response: API response object
    /// - Returns: `true` if successful otherwise false
    func isResponseSuccess(_ response: Any?) -> Bool {
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
    
    //MARK: - TrustKit
    /// Get `TrustKit` object for public key pinning.
    class func getTrustKit() -> TrustKit {
        let trustKitConfig: [String : Any] = [
            kTSKSwizzleNetworkDelegates: false,
            kTSKPinnedDomains: [
                "api.ost.com": [
                    kTSKPublicKeyHashes: [
                        "s4vrk6by0cqKQ9p/mFOakoi0daivc7Le8q7fUuuo4/U=",
                        "MvVeCJ2tAuJZmbqoXMqSNP2mKh+VjGiljvqWytjzasU=",
                        "J+0IGhy08mkHR1Z1WbdrHEdHhXRohrdLHUYORlWGafA=",
                        "aF+lKYb0WChlCTx5uPBw5ZWze/98vAXSzBBIrVSZWJE=",
                        "efgWbb0q/zHFLub1SY5QpoQVlZp33QpLOj0EmhoK8tI=",
                    ],
                    kTSKIncludeSubdomains: false,
                    kTSKEnforcePinning: true,
                ]
            ]
        ]
        return TrustKit(configuration: trustKitConfig)
    }
    
    //MARK: - Private
    /// Get domain from given url string
    ///
    /// - Parameter urlString: URL
    /// - Returns: Domain string
    private class func getDomainFor(_ urlString: String) -> String? {
        let url = URL(string: urlString)
        return url?.host
    }
}
