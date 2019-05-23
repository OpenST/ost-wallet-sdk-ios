/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */


import Foundation

public class OstApiError: OstError {

    override init(_ code: String, _ messageTextCode: OstErrorText,  _ errorInfo:[String:Any]? = nil) {
        super.init(code, messageTextCode, errorInfo);
        self.isApiError = true;
    }
    
    override init(_ code: String, msg errorMessage: String) {
        super.init(code, msg: errorMessage)
        self.isApiError = true
    }
    
    override init(fromApiResponse response: [String: Any]) {
        super.init(fromApiResponse: response)
        self.isApiError = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public func getApiErrorCode() -> String? {
        return (self.errorInfo?["err"] as? [String: Any])?["code"] as? String
    }
    
    @objc
    public func getApiErrorMessage() -> String? {
        return (self.errorInfo?["err"] as? [String: Any])?["msg"] as? String
    }
    
    @objc
    public func getApiInternalId() -> String? {
        return (self.errorInfo?["err"] as? [String: Any])?["internal_id"] as? String
    }
    
    @objc
    public func isBadRequest() -> Bool {
        guard let errorCode = getApiErrorCode() else {
            return false
        }
        return "BAD_REQUEST".caseInsensitiveCompare(errorCode) == .orderedSame
    }

    @objc
    func isNotFound() -> Bool {
        guard let errorCode = getApiErrorCode() else {
            return false
        }
        return "NOT_FOUND".caseInsensitiveCompare(errorCode) == .orderedSame
    }
    
    @objc
    public func isDeviceTimeOutOfSync() -> Bool{
        return isParameterIncludedInError(parameter: "api_request_timestamp");
    }
    
    @objc
    public func isApiSignerUnauthorized() -> Bool{
        return isParameterIncludedInError(parameter: "api_key");    
    }
    
    private func isParameterIncludedInError(parameter: String) -> Bool {
        guard let errorData:[[String:Any]] = (self.errorInfo?["err"] as? [String: Any])?["error_data"] as? [[String:Any]] else {
            return false
        }
        var isIncluded: Bool = false
        errorData.forEach { (err:[String : Any]) in
            if let errorParam = err["parameter"] as? String {
                if (parameter.caseInsensitiveCompare(errorParam) == .orderedSame) {
                    isIncluded = true
                }
            }
        }
        return isIncluded;
    }

}
