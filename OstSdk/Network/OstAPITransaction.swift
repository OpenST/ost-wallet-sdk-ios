//
//  OstAPITransaction.swift
//  OstSdk
//
//  Created by aniket ayachit on 26/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAPITransaction: OstAPIBase {
    
    let transactionApiResourceBase: String
    override init(userId: String) {
        self.transactionApiResourceBase = "/users/\(userId)/transactions"
        super.init(userId: userId)
    }
    
    func executeTransaction(params: [String: Any], onSuccess: ((OstTransaction)-> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = self.transactionApiResourceBase
        
        var executeTransactionParams = params
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &executeTransactionParams, withUserId: self.userId)
        
        post(params: executeTransactionParams as [String: AnyObject],
             onSuccess: { (apiResponse) in
                do {
                    let transaction = try OstAPIHelper.getEntityFromAPIResponse(apiResponse: apiResponse)
                    onSuccess?(transaction as! OstTransaction)
                }catch let error{
                    onFailure?(error as! OstError)
                }
        }) { (failureResponse) in
            onFailure?(OstError.init(fromApiResponse: failureResponse!))
        }
    }
    
    func getTransaction(transcionId: String, onSuccess: ((OstTransaction) -> Void)?, onFailure: ((OstError) -> Void)?) throws {
        resourceURL = self.transactionApiResourceBase + "/" + transcionId
        
        var params: [String: Any] = [:]
        // Sign API resource
        try OstAPIHelper.sign(apiResource: getResource, andParams: &params, withUserId: self.userId)

        get(params: params as [String: AnyObject], onSuccess: { (apiResponse) in
            do {
                let transaction = try OstAPIHelper.getEntityFromAPIResponse(apiResponse: apiResponse)
                onSuccess?(transaction as! OstTransaction)
            }catch let error{
                onFailure?(error as! OstError)
            }
        }) { (failureResponse) in
            onFailure?(OstError.init(fromApiResponse: failureResponse!))
        }
    }
}
