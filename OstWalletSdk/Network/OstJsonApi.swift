/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

/// Ost api delegate
@objc public protocol OstApiDelegate: AnyObject {
    
}

/// Ost Api delegate
@objc public protocol OstJsonApiDelegate: OstApiDelegate {
    /// Success callback for API
    ///
    /// - Parameter data: Success API response
    func onOstJsonApiSuccess(data:[String:Any]?);
    
    /// Failure callback for API
    ///
    /// - Parameters:
    ///   - error: OstError
    ///   - errorData: Failure API response
    func onOstJsonApiError(error:OstError?, errorData:[String:Any]?);
}


@objc public class OstJsonApi:NSObject {
    
    /// Get result type for given api data.
    /// It reads key `result_type` from given parameter. Returns `nil` if not present.
    ///
    /// - Parameter data: Api response
    /// - Returns: String
    @objc public class func getResultType(apiData data:[String:Any]?) -> String? {
        return data?["result_type"] as? String;
    }
    
    /// Get value for `result_type` as dictionary.
    ///
    /// - Parameter data: Api response
    /// - Returns: Dictionary
    @objc public class func getResultAsDictionary(apiData data:[String:Any]?) -> [String:Any]? {
        if ( nil != data ) {
            let resultType:String? = data?["result_type"] as? String;
            if ( nil != resultType ) {
                return data?[ resultType! ] as? [String:Any];
            }
        }
        return nil;
    }
    
    /// Get value for `result_type` as Array
    ///
    /// - Parameter data: Api response
    /// - Returns: Dictionary
    @objc public class func getResultAsArray(apiData data:[String:Any]?) -> [Any]? {
        if ( nil != data ) {
            let resultType:String? = data?["result_type"] as? String;
            if ( nil != resultType ) {
                return data?[ resultType! ] as? [Any];
            }
        }
        return nil;
    }
    
    /// Get api success callback.
    ///
    /// - Parameter delegate: OstJsonApiDelegate
    @objc public class func getApiSuccessCallback(delegate:OstJsonApiDelegate) -> (([String: Any]?) -> Void) {
        let callback: (([String: Any]?) -> Void) = { (data) in
            delegate.onOstJsonApiSuccess(data: data);
        };
        return callback;
    }
    
    /// Get api failure callback.
    ///
    /// - Parameter delegate: OstJsonApiDelegate
    @objc public class func getApiErrorCallback(delegate:OstJsonApiDelegate) -> (([String: Any]?) -> Void) {
        let callback: (([String: Any]?) -> Void) = { (failureResponse) in
            let error = OstApiError.init(fromApiResponse: failureResponse!);
            delegate.onOstJsonApiError(error: error, errorData: failureResponse);
        };
        return callback;
    }
    
    /// Get balance from server
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - delegate: Callback
    @objc public class func getBalance(forUserId userId:String, delegate:OstJsonApiDelegate) {
        do {
            try OstAPIUser.init(userId: userId)
                .getBalance(onSuccess: self.getApiSuccessCallback(delegate: delegate),
                            onFailure: self.getApiErrorCallback(delegate: delegate));
        } catch let error {
            delegate.onOstJsonApiError(error: (error as! OstError), errorData: nil);
        }
    }
    
    /// Get price point from server
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - delegate: Callback
    @objc public class func getPricePoint(forUserId userId:String, delegate:OstJsonApiDelegate) {
        do {
            try OstAPIChain(userId: userId)
                .getPricePointData(onSuccess: self.getApiSuccessCallback(delegate: delegate),
                               onFailure: self.getApiErrorCallback(delegate: delegate))
        } catch let error {
            delegate.onOstJsonApiError(error: (error as! OstError), errorData: nil);
        }
    }

    /// Get balance with price point from server
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - delegate: Callback
    @objc public class func getBalanceWithPricePoint(forUserId userId:String, delegate:OstJsonApiDelegate) {
        do {
            let failureCallback = self.getApiErrorCallback(delegate: delegate);
            try OstAPIUser.init(userId: userId).getBalance(onSuccess: { (balanceData) in
                do {
                    try OstAPIChain(userId: userId).getPricePoint(onSuccess: { (pricePointData) in
                        let pricePoint = ["price_point": pricePointData]
                        var finalData:[String:Any] = [:];
                        finalData.merge(dict: pricePoint);
                        finalData.merge(dict: balanceData!);
                        delegate.onOstJsonApiSuccess(data: finalData);
                    }, onFailure: { (ostError) in
                        delegate.onOstJsonApiError(error: ostError, errorData: nil);
                    });
                } catch let error {
                    delegate.onOstJsonApiError(error: (error as! OstError), errorData: nil);
                }
            },
                                                           onFailure: failureCallback);
        } catch let error {
            delegate.onOstJsonApiError(error: (error as! OstError), errorData: nil);
        }
    }
    
    /// Get transaction from server
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - params: transaction params
    ///   - delegate: Callback
    @objc public class func getTransactions(forUserId userId:String, params:[String:Any]?, delegate:OstJsonApiDelegate) {
        do {
            try OstAPIUser.init(userId: userId)
                .getTransactions(params:params,
                                 onSuccess: self.getApiSuccessCallback(delegate: delegate),
                                 onFailure: self.getApiErrorCallback(delegate: delegate));
        } catch let error {
            delegate.onOstJsonApiError(error: (error as! OstError), errorData: nil);
        }
    }
    
    /// Get pending recovery from server
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - delegate: Callback
    @objc public class func getPendingRecovery(forUserId userId:String, delegate:OstJsonApiDelegate) {
        do {
            try OstAPIDevice(userId: userId)
                .getJsonPendingRecovery(params: nil,
                                        onSuccess: self.getApiSuccessCallback(delegate: delegate),
                                        onFailure: self.getApiErrorCallback(delegate: delegate))
            
        } catch let error {
            delegate.onOstJsonApiError(error: (error as! OstError), errorData: nil);
        }
    }
    
    /// Get device list from server
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - params: transaction params
    ///   - delegate: Callback
    @objc public class func getDeviceList(forUserId userId:String, params:[String:Any]?, delegate:OstJsonApiDelegate) {
        do {
            try OstAPIDevice(userId: userId)
                .getDeviceList(params: params,
                               onSuccess: self.getApiSuccessCallback(delegate: delegate),
                               onFailure: self.getApiErrorCallback(delegate: delegate));
        } catch let error {
            delegate.onOstJsonApiError(error: (error as! OstError), errorData: nil);
        }
    }
    
    /// Get current device from server
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - delegate: Callback
    @objc public class func getCurrentDevice(forUserId userId:String,
                                             delegate:OstJsonApiDelegate) {
        do {
            try OstAPIDevice(userId: userId)
                .getCurrentDeviceJsonApi(onSuccess: self.getApiSuccessCallback(delegate: delegate),
                                         onFailure: self.getApiErrorCallback(delegate: delegate));
        } catch let error {
            delegate.onOstJsonApiError(error: (error as! OstError), errorData: nil);
        }
    }
    
    
    /// Get  user redeemable skus  from server
      ///
      /// - Parameters:
      ///   - userId: User Id
      ///   - params: redeemable skus params
      ///   - delegate: Callback
   @objc public class func getRedeemableSkus(userId:String, params:[String:Any]?, delegate:OstJsonApiDelegate) {
      do {
       try OstRedemption.init(userId: userId)
        .getRedeemableSkus(params: params,
                           onSuccess: self.getApiSuccessCallback(delegate: delegate),
                           onFailure: self.getApiErrorCallback(delegate: delegate))
      } catch let error {
          delegate.onOstJsonApiError(error: (error as! OstError), errorData: nil);
      }
   }
    
    /// Get  user redeemable skus details from server
       ///
       /// - Parameters:
       ///   - userId: User Id
        ///  - skuId: sku Id
       ///   - params: redeemable sku details params
       ///   - delegate: Callback
    @objc public class func getRedeemableSkuDetails(userId:String, skuId: String, params:[String:Any]?, delegate:OstJsonApiDelegate) {
       do {
        try OstRedemption.init(userId: userId)
            .getRedeemableSkuDetails(id: skuId, params: params,
                                     onSuccess:self.getApiSuccessCallback(delegate: delegate),
                                     onFailure:self.getApiErrorCallback(delegate: delegate))
       } catch let error {
           delegate.onOstJsonApiError(error: (error as! OstError), errorData: nil);
       }
    }
    
    
}

