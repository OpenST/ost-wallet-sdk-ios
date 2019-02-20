//
//  OstPerform+AddSession.swift
//  OstSdk
//
//  Created by aniket ayachit on 20/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

extension OstPerform {
    
    func authorizeSession() throws {
        let sessionAddress: String  =  (self.payload!["session_address"])!
        let spendingLimit: String = (self.payload!["spending_limit"])!
        let expirationHeight: String = (self.payload!["expiration_height"])!
        
        let abiMethodName = "authorizeSession"
        
        let encodedABIHex = try GnosisSafe().getAddSessionExecutableData(abiMethodName: abiMethodName, sessionAddress: sessionAddress, expirationHeight: expirationHeight, spendingLimit: spendingLimit)
        
        let user = try self.getUser()
        if (nil == user) {
            throw OstError.invalidInput("User is not present.")
        }
        let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(to: user!.tokenHolderAddress!,
                                                                           value: "0",
                                                                           data: encodedABIHex,
                                                                           operation: "0",
                                                                           safeTxGas: "0",
                                                                           dataGas: "0",
                                                                           gasPrice: "0",
                                                                           gasToken: self.nullAddress,
                                                                           refundReceiver: self.nullAddress,
                                                                           nonce: "0")
        let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any], primaryType: typedDataInput["primaryType"] as! String, domain: typedDataInput["domain"] as! [String: String], message: typedDataInput["message"] as! [String: Any])
        let signingHash = try! eip712.getEIP712SignHash()
        
        let params: [String: Any] = ["data_defination":self.dataDefination!,
                                     "to": user!.tokenHolderAddress!,
                                     "value": "0",
                                     "calldata": encodedABIHex,
                                     "raw_calldata": ["method": abiMethodName,
                                                      "parameters": [sessionAddress, spendingLimit, expirationHeight]],
                                     "operation": "0",
                                     "safe_tx_gas": "0",
                                     "data_gas": "0",
                                     "gas_price": "0",
                                     "gas_token": self.nullAddress,
                                     "refund_receiver": self.nullAddress,
                                     "signer": user!.currentDevice!.address!,
                                     "signature": signingHash
        ]
        
        try OstAPISession(userId: self.userId).authorizeSession(params: params, onSuccess: { (ostSession) in
            self.postFlowCompleteForAddSession(entity: ostSession)
        }, onFailure: { (ostError) in
            self.postError(ostError)
        })
    }
    
    func postFlowCompleteForAddSession(entity: OstSession) {
        Logger.log(message: "OstAddSession flowComplete", parameterToPrint: entity.data)
        
        DispatchQueue.main.async {
            let contextEntity: OstContextEntity = OstContextEntity(type: .addSession , entity: entity)
            self.delegate.flowComplete(contextEntity);
        }
    }
}
