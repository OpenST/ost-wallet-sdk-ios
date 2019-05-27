//
//  CurrentToken.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 04/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstWalletSdk

class CurrentEconomy: OstBaseModel {
    
    static let userDefaultsId = "CurrentEconomy"
    static let getInstance = CurrentEconomy()
    
    private var economyDecimals: Int? = nil
    func getEconomyDecimals() -> Int {
        if nil == economyDecimals {
            if let currentToken = OstWalletSdk.getToken(tokenId!) {
                let decimals = currentToken.decimals ?? 18
                economyDecimals = decimals
            }
        }

        return economyDecimals ?? 18
    }
    
    private override init() {
        if let economy = UserDefaults.standard.string(forKey: CurrentEconomy.userDefaultsId),
            let qrJsonData = EconomyScannerViewController.getQRJsonData(economy) {
            economyDetails = qrJsonData as [String : Any]
        }
    }
    
    var economyDetails: [String: Any]? = nil
    
}

extension CurrentEconomy {
    
    var urlId: String? {
        return ConversionHelper.toString(economyDetails?["url_id"])
    }
    
    var tokenId: String? {
       return ConversionHelper.toString(economyDetails?["token_id"])
    }
    
    var viewEndPoint: String? {
        return economyDetails?["view_api_endpoint"] as? String
    }
    
    var mappyApiEndpoint: String? {
        return economyDetails?["mappy_api_endpoint"] as? String
    }
    
    var tokenSymbol: String? {
        return economyDetails?["token_symbol"] as? String
    }
    
    var saasApiEndpoint: String? {
        return economyDetails?["saas_api_endpoint"] as? String
    }
    
    var tokenName: String? {
        return economyDetails?["token_name"] as? String
    }
    
    var auxiliaryChainId: String? {
        let token = OstWalletSdk.getToken(tokenId!)
        return token?.auxiliaryChainId
    }
    
    var utilityBrandedToken: String? {
        let token = OstWalletSdk.getToken(tokenId!)
        return (token?.data["auxiliary_chains"] as! [[String: Any]])[0]["utility_branded_token"] as! String
    }
  
}
