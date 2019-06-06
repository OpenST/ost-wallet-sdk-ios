/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import EthereumKit

class OstAPISigner {
    
    /// User id associated with the API keys
    private let userId: String
    private let keyManagerDelegate: OstKeyManagerDelegate
    
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - keyManagerDelegate: OstKeyManagerDelegate
    init(userId: String,
         keyManagerDelegate: OstKeyManagerDelegate) {
        
        self.userId = userId
        self.keyManagerDelegate = keyManagerDelegate
    }
    
    /// Sign the api url with the private key
    ///
    /// - Parameters:
    ///   - resource: API url string
    ///   - params: API url associated paramters
    /// - Returns: Signed string
    /// - Throws: OSTError
    func sign(resource: String, params: [String: Any?]) throws -> String {
        let queryString: String = getQueryString(for: params)
        let message = "\(resource)?\(queryString)"
        return try self.keyManagerDelegate.signWithAPIKey(message: message)
    }
    
    /// Build the query string from dictionary
    ///
    /// - Parameter paramValObj: Params dictionary
    /// - Returns: Formated query string
    private func getQueryString(for paramValObj:[String: Any?]) -> String {
        var nestedQueryParams: [HttpParam] = []
        _ = OstUtils.buildNestedQuery(params: &nestedQueryParams, paramKeyPrefix: "", paramValObj: paramValObj)
        return nestedQueryParams.map {
            let encodedKeyString = $0.getParamName().encodedString
            let encodedValueString = $0.getParamValue().encodedString
            return encodedKeyString + "=" + encodedValueString }.joined(separator: "&")
    }
}
