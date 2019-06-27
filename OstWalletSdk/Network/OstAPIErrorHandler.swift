/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import Alamofire

/// Format the error response
class OstAPIErrorHandler {
    
    /// API error code
    enum APIErrorCode: String {
        case
        SOMETHING_WENT_WRONG,
        NOT_FOUND,
        TOO_MANY_REQUESTS,
        INTERNAL_SERVER_ERROR,
        BAD_GATEWAY,
        SERVICE_UNAVAILABLE,
        GATEWAY_TIMEOUT,
        BAD_URL,
        NOT_CONNECTED_TO_INTERNET,
        REQUEST_TIMED_OUT,
        INVALID_CERTIFICATE
    }

    /// Get the formated error response data
    ///
    /// - Parameter response: HTTP data response
    /// - Returns: Formated response dictionary
    class func getErrorResponse(_ response: DataResponse<Any>) -> [String : Any] {
        // Check if the data is already formatted.
        let responseValue: [String : Any]?  = response.result.value as? [String : Any]
        if (responseValue != nil && responseValue!["success"] != nil && responseValue!["err"] != nil){
            return responseValue!
        }
        var code: String = APIErrorCode.SOMETHING_WENT_WRONG.rawValue
        var errorMessage: String = "Something went wrong."
        if (response.response != nil) {
            switch response.response!.statusCode {
            case 404:
                code = APIErrorCode.NOT_FOUND.rawValue
                errorMessage = "The requested resource could not be located."
            case 429:
                code = APIErrorCode.TOO_MANY_REQUESTS.rawValue
                errorMessage = "Too many requests."
            case 500:
                code = APIErrorCode.INTERNAL_SERVER_ERROR.rawValue
                errorMessage = "Internal server error."
            case 502:
                code = APIErrorCode.BAD_GATEWAY.rawValue
                errorMessage = "Bad gateway."
            case 503:
                code = APIErrorCode.SERVICE_UNAVAILABLE.rawValue
                errorMessage = "Service unavailable."
            case 504:
                code = APIErrorCode.GATEWAY_TIMEOUT.rawValue
                errorMessage = "Gateway timeout."
            default:
                code = APIErrorCode.SOMETHING_WENT_WRONG.rawValue
                errorMessage = "Something went wrong."
            }
        } else if (response.error != nil) {
            let errorCode = (response.error! as NSError).code
            switch errorCode {
            case -1000:
                code = APIErrorCode.BAD_URL.rawValue
                errorMessage = "The connection failed due to a malformed URL."
            case -1001:
                code = APIErrorCode.REQUEST_TIMED_OUT.rawValue
                errorMessage = "The connection timed out."
            case -1009:
                code = APIErrorCode.NOT_CONNECTED_TO_INTERNET.rawValue
                errorMessage = "The connection failed because the device is not connected to the internet."
            case -999:
                code = APIErrorCode.INVALID_CERTIFICATE.rawValue
                errorMessage = "Certificate provided by Ost platform is invalid Or it has been compromised. Please re-try in some other network and if the problem persists contact support@ost.com."
            default:
                code = APIErrorCode.SOMETHING_WENT_WRONG.rawValue
                errorMessage = "Something went wrong."
            }
        }
        return OstAPIErrorHandler.getResponse(code, errorMessage)
    }
    
    /// Get formated response when there is no internet connectivity
    ///
    /// - Returns: Formated response dictionary
    class func getNoInternetConnectivityResponse() -> [String : Any] {
        return OstAPIErrorHandler.getResponse(
            APIErrorCode.NOT_CONNECTED_TO_INTERNET.rawValue,
            "The connection failed because the device is not connected to the internet."
        )
    }
    
    /// Get the formatted response with provided error code and error message
    ///
    /// - Parameters:
    ///   - errorCode: Error code
    ///   - errorMessage: Error message
    /// - Returns: Formated response dictionary
    private class func getResponse(_ errorCode: String, _ errorMessage: String) -> [String : Any] {
        let errorResponse: [String : Any] = [
            "err": [
                "code": "\(errorCode)",
                "error_data": [],
                "internal_id": "SDK(\(errorCode))",
                "msg": "\(errorMessage)"
            ],
            "success": 0
        ]
        return errorResponse
    }
}
