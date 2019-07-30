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
    
    func getEconomyDecimals() -> Int {
        let currentToken = OstWalletSdk.getToken(tokenId!)!
        let decimals = currentToken.decimals
        return decimals!
    }
    
    private override init() {
        var testEconomy: String? = "{\"token_id\": 1140,\"token_name\":\"T21054\",\"token_symbol\":\"T214\",\"url_id\":\"79141f46c37ba37c31cce9aa477a6336902de60a6da19644e7e768f1739940f3\",\"mappy_api_endpoint\":\"https://demo-mappy.stagingost.com/demo/\",\"saas_api_endpoint\":\"https://api.stagingost.com/testnet/v2/\",\"view_api_endpoint\":\"https://view.stagingost.com/testnet/\"}"
        if let economy = testEconomy,
//        if let economy = UserDefaults.standard.string(forKey: CurrentEconomy.userDefaultsId),
            let qrJsonData = CurrentEconomy.getQRJsonData(economy) {
            _economyDetails = qrJsonData as [String : Any]
        }
    }
    private var _economyDetails: [String: Any]? = nil;
    
    var economyDetails: [String: Any]? {
        get {
            return _economyDetails;
        }
        set {
            _economyDetails = newValue;
            if (nil != _economyDetails ) {
                let jsonDetails = OstUtils.dictionaryToJSONString(dictionary: _economyDetails!);
                if (nil != jsonDetails ) {
                    UserDefaults.standard.set(jsonDetails, forKey: CurrentEconomy.userDefaultsId)
                    UserDefaults.standard.synchronize()
                } else {
                    _economyDetails = nil;
                }
            }
        }
    }
    
    class func getQRJsonData(_ qr: String) -> [String: Any?]? {
        let jsonObj: [String:Any?]?
        do {
            jsonObj = try OstUtils.toJSONObject(qr) as? [String : Any?]
        } catch {
            return nil
        }
        
        let viewEndPoint = jsonObj!["view_api_endpoint"] as? String
        let tokenId = jsonObj!["token_id"]
        let mappyApiEndpoint = jsonObj!["mappy_api_endpoint"]
        let tokenSymbol = jsonObj!["token_symbol"]
        
        if nil == viewEndPoint || nil == tokenId || nil == mappyApiEndpoint || nil == tokenSymbol {
            return nil
        }
        
        return jsonObj
    }
    
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
    
    var companyTokenHolders: [String]? {
        let token = OstWalletSdk.getToken(tokenId!)
        return (token?.data["auxiliary_chains"] as! [[String: Any]])[0]["company_token_holders"] as? [String]
    }
  
}
