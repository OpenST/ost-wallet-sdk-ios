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
    private var apiKey: String?
    
    /// Get OstAPISigner object for the given user id
    ///
    /// - Parameter userId: User Id for which the API keys will be used for signing
    /// - Returns: OstAPISigner object
    /// - Throws: OSTError
    class func getApiSigner(forUserId userId: String) throws -> OstAPISigner{
        let apiSigner = OstAPISigner(userId: userId)
        do {
            _ = try apiSigner.getApiKey();
        } catch {
            throw OstError1.init("s_i_as_gas_1", .noPrivateKeyFound)
        }
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
        return try personalSign(message)
    }
    
    /// Get API private key for signing
    ///
    /// - Returns: API private key
    /// - Throws: OSTError
    private func getApiKey() throws -> String {
        if (self.apiKey == nil) {
            do {
                self.apiKey = try OstKeyManager(userId: userId).getAPIKey()
            } catch {
                throw OstError1.init("s_i_as_gak_1", .noPrivateKeyFound)
            }
        }
        return self.apiKey!
    }
    
    /// Do personal sign of the message
    ///
    /// - Parameter message: Message string that needs to be signed
    /// - Returns: Signed message string
    /// - Throws: OSTError
    private func personalSign(_ message: String) throws -> String {
        let apiPrivateKey = try getApiKey()

        let wallet : Wallet = Wallet(network: OstConstants.OST_WALLET_NETWORK,
                                     privateKey: apiPrivateKey,
                                     debugPrints: OstConstants.PRINT_DEBUG)

        let singedData: String
        do {
            singedData = try wallet.personalSign(message: message)
        } catch {
            throw OstError1.init("s_i_as_ps_1", .signTxFailed)
        }
        return singedData.addHexPrefix()
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
