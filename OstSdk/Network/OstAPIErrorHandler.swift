//
//  OstAPIErrorHandler.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 23/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire

/// Format the error response
class OstAPIErrorHandler {

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
        var code: String = "SOMETHING_WENT_WRONG"
        var errorMessage: String = "Something went wrong."
        if (response.response != nil) {
            switch response.response!.statusCode {
            case 404:
                code = "NOT_FOUND"
                errorMessage = "The requested resource could not be located."
            case 429:
                code = "TOO_MANY_REQUESTS"
                errorMessage = "Too many requests."
            case 500:
                code = "INTERNAL_SERVER_ERROR"
                errorMessage = "Internal server error."
            case 502:
                code = "BAD_GATEWAY"
                errorMessage = "Bad gateway."
            case 503:
                code = "SERVICE_UNAVAILABLE"
                errorMessage = "Service unavailable."
            case 504:
                code = "GATEWAY_TIMEOUT"
                errorMessage = "Gateway timeout."
            default:
                code = "SOMETHING_WENT_WRONG"
                errorMessage = "Something went wrong."
            }
        } else if (response.error != nil) {
            let errorCode = (response.error! as NSError).code
            switch errorCode {
            case -1000:
                code = "BAD_URL"
                errorMessage = "The connection failed due to a malformed URL."
            case -1001:
                code = "REQUEST_TIMED_OUT"
                errorMessage = "The connection timed out."
            case -1009:
                code = "NOT_CONNECTED_TO_INTERNET"
                errorMessage = "The connection failed because the device is not connected to the internet."
            default:
                code = "SOMETHING_WENT_WRONG"
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
            "NOT_CONNECTED_TO_INTERNET",
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
