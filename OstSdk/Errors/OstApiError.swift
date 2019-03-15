//
//  OstApiError.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 15/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstApiError: OstError {

    override init(_ code: String, _ messageTextCode: OstErrorText) {
        super.init(code, messageTextCode)
        self.isApiError = true
    }
    
    override init(_ code: String, _ errorMessage: String) {
        super.init(code, errorMessage)
        self.isApiError = true
    }
    
    override init(fromApiResponse response: [String: Any]) {
        super.init(fromApiResponse: response)
        self.isApiError = true
    }
    
    
    public func getApiErrorCode() -> String? {
        return (self.errorInfo?["err"] as? [String: Any])?["code"] as? String
    }
    
    public func getApiErrorMessage() -> String? {
        return (self.errorInfo?["err"] as? [String: Any])?["msg"] as? String
    }
    
    public func getApiInternalId() -> String? {
        return (self.errorInfo?["err"] as? [String: Any])?["internal_id"] as? String
    }
    
    public func isBadRequest() -> Bool {
        guard let errorCode = getApiErrorCode() else {
            return false
        }
        return "BAD_REQUEST".caseInsensitiveCompare(errorCode) == .orderedSame
    }
    
    public func isDeviceTimeOutOfSync() -> Bool{
        return isParameterIncludedInError(parameter: "api_request_timestamp");
    }
    
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
