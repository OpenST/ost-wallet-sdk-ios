//
//  OstAPISigner.swift
//  OstSdk
//
//  Created by aniket ayachit on 04/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import EthereumKit


struct ApiSigner {
    var userId: String
    var APIKey: String
    
    init(userId: String, APIKey: String) {
        self.userId = userId
        self.APIKey = APIKey
    }
}

class OstAPISigner {
    private static var apiSigner: ApiSigner? = nil
    
    var userId: String
    init(userId: String) {
        self.userId = userId
    }
    
    func getAPISigner() -> ApiSigner? {
        return OstAPISigner.apiSigner
    }
    
    private func setAPIKey(_ apiKey: String, forUserId userId: String) {
        OstAPISigner.apiSigner = ApiSigner(userId: userId, APIKey: apiKey)
    }
    
    func personalSign(_ message: String) throws -> String {
        var apiPrivateKey: String? = nil
        
        if let apiSigner = getAPISigner() {
            if (apiSigner.userId == self.userId) {
                apiPrivateKey = apiSigner.APIKey
            }
        }
        if (apiPrivateKey == nil) {
            if let apiKey = try OstKeyManager(userId: userId).getAPIKey() {
                setAPIKey(apiKey, forUserId: userId)
                apiPrivateKey = apiKey
            }
        }
        if (apiPrivateKey == nil) {
            throw OstError.actionFailed("Signing message action failed.")
        }
        
        let wallet : Wallet = Wallet(network: .mainnet, privateKey: apiPrivateKey!, debugPrints: false)
        let singedData = try wallet.personalSign(message: message)
        return singedData.addHexPrefix()
    }
    
    func sign(resource: String, params: [String: Any?]) throws -> (String, String) {
        let queryString: String = getQueryString(for: params)
        let message = resource + "?" + queryString
        Logger().DLog(message: "queryString", parameterToPrit: message)
        return (try personalSign(message), message)
    }
    
    func getQueryString(for paramValObj:[String: Any?]) -> String {
        var nestedQueryParams: [HttpParam] = []
        _ = OstUtils.buildNestedQuery(params: &nestedQueryParams, paramKeyPrefix: "", paramValObj: paramValObj)
        return nestedQueryParams.map {"\($0.getParamName())=\($0.getParamValue())"}.joined(separator: "&")
    }
}
