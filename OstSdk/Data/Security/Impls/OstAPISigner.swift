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
    
    private static func getAPISigner() -> ApiSigner? {
        return self.apiSigner
    }
    private static func setAPIKey(_ apiKey: String, forUserId userId: String) {
        self.apiSigner = ApiSigner(userId: userId, APIKey: apiKey)
    }
    
    var userId: String
    init(userId: String) {
        self.userId = userId
    }
    
    func personalSign(_ message: String) throws -> String {
        var apiPrivateKey: String? = nil
        if let apiSigner = OstAPISigner.getAPISigner() {
            if (apiSigner.userId == self.userId) {
                apiPrivateKey = apiSigner.APIKey
            }
        }
        if (apiPrivateKey == nil) {
            if let apiKey = try OstKeyManager(userId: userId).getAPIKey() {
                OstAPISigner.setAPIKey(apiKey, forUserId: userId)
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
}
