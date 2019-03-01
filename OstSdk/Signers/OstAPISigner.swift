//
//  OstAPISigner.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import EthereumKit

class OstAPISigner {
    
    /// User id associated with the API keys
    var userId: String
    
    /// API private key
    private var apiKey: String? = nil
    
    /// Get OstAPISigner object for the given user id
    ///
    /// - Parameter userId: User Id for which the API keys will be used for signing
    /// - Returns: OstAPISigner object
    class func getApiSigner(forUserId userId: String) -> OstAPISigner{
        let apiSigner = OstAPISigner(userId: userId)
        return apiSigner;
    }
    
    /// Initializer
    ///
    /// - Parameter userId: User Id for which the API keys will be used for signing
    init(userId: String) {
        self.userId = userId
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
        let keyManager = OstKeyManager(userId: self.userId);
        return try keyManager.signWithAPIKey(message: message)
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
