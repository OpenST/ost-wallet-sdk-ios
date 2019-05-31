/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc public protocol OstApiDelegate: AnyObject {}

@objc public protocol OstBasicApiDelegate: OstApiDelegate {
    @objc func onSuccess(data:[String:Any]?, apiResonse:[String:Any]?);
    @objc func onError(error:[String:Any]?, apiResonse:[String:Any]?);
}


public extension OstWalletSdk.Api {
    @objc class func getResultTypeDictionary(data:[String:Any]) -> [String:Any] {
        
        return [:];
    }

    @objc class func getResultTypeArray(data:[String:Any]) -> [Any] {
        
        return [];
    }
    
    @objc class func getBalance(userId:String, fetchPriceOracle:Bool = true, delegate:OstBasicApiDelegate) {
        
    }
    
    @objc class func getTransactions(forUserId:String, payload:[String:Any], delegate:OstBasicApiDelegate) {
        
    }

    @objc class func getTransaction(forUserId:String, transactionId:String, delegate:OstBasicApiDelegate) {
        
    }
}
