//
//  OstPerform+AddSession.swift
//  OstSdk
//
//  Created by aniket ayachit on 20/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAuthorizeSession {
    
    let abiMethodName = "authorizeSession"
    let dataDefination = OstPerform.DataDefination.AUTHORIZE_SESSION.rawValue
    let nullAddress = "0x0000000000000000000000000000000000000000"

    var deviceManager: OstDeviceManager? = nil
    
    let userId: String
    let sessionAddress: String
    let spendingLimit: String
    let expirationHeight: String
    let generateSignatureCallback: ((String) -> (String?, String?))
    let onSuccess: ((OstSession)-> Void)
    let onFailure: ((OstError) -> Void)
    
    init(userId: String,
         sessionAddress: String,
         spendingLimit: String,
         expirationHeight: String,
         generateSignatureCallback: @escaping ((String) -> (String?, String?)),
         onSuccess: @escaping ((OstSession)-> Void),
         onFailure: @escaping ((OstError) -> Void)) {
        
        self.userId = userId
        self.sessionAddress = sessionAddress
        self.spendingLimit = spendingLimit
        self.expirationHeight = expirationHeight
        self.generateSignatureCallback = generateSignatureCallback
        
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    func perform() {
        do {
            try self.fetchDeviceManager()
        }catch let error {
            self.onFailure(error as! OstError)
        }
    }
    
    func fetchDeviceManager() throws {
        try OstAPIDeviceManager(userId: self.userId).getDeviceManager(onSuccess: { (ostDeviceManager) in
            self.deviceManager = ostDeviceManager
            self.authorizeSession()
        }) { (ostError) in
            self.onFailure(ostError)
        }
    }
    
    func authorizeSession() {
        do {
            let encodedABIHex = try GnosisSafe().getAddSessionExecutableData(abiMethodName: self.abiMethodName, sessionAddress: self.sessionAddress, expirationHeight: self.expirationHeight, spendingLimit: self.spendingLimit)
            
            let user = try OstUser.getById(self.userId)
            if (nil == user) {
                throw OstError.invalidInput("User is not present.")
            }
            
            if (nil == self.deviceManager) {
                throw OstError.actionFailed("Device manager is not persent.")
            }
            
            let deviceManagerNonce = self.deviceManager!.nonce
            let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(verifyingContract: self.deviceManager!.address!,
                                                                               to: user!.tokenHolderAddress!,
                                                                               value: "0",
                                                                               data: encodedABIHex,
                                                                               operation: "0",
                                                                               safeTxGas: "0",
                                                                               dataGas: "0",
                                                                               gasPrice: "0",
                                                                               gasToken: self.nullAddress,
                                                                               refundReceiver: self.nullAddress,
                                                                               nonce: OstUtils.toString(deviceManagerNonce)! )
            let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any], primaryType: typedDataInput["primaryType"] as! String, domain: typedDataInput["domain"] as! [String: String], message: typedDataInput["message"] as! [String: Any])
            let signingHash = try! eip712.getEIP712SignHash()
            
            let (signature, signerAddress) = self.generateSignatureCallback(signingHash)
            
            if (nil == signature || signature!.isEmpty) {
                throw OstError.actionFailed("signature is not generated")
            }
            
            if (nil == signerAddress || signerAddress!.isEmpty) {
                throw OstError.actionFailed("signer address is not generated")
            }
            
            try self.deviceManager!.updateNonce(deviceManagerNonce+1)
            
            let params: [String: Any] = ["data_defination":self.dataDefination,
                                         "to": user!.tokenHolderAddress!,
                                         "value": "0",
                                         "calldata": encodedABIHex,
                                         "raw_calldata": ["method": abiMethodName,
                                                          "parameters": [sessionAddress, spendingLimit, expirationHeight]],
                                         "operation": "0",
                                         "safe_tx_gas": "0",
                                         "data_gas": "0",
                                         "gas_price": "0",
                                         "nonce": OstUtils.toString(deviceManagerNonce)!,
                                         "gas_token": self.nullAddress,
                                         "refund_receiver": self.nullAddress,
                                         "signers": [signerAddress!],
                                         "signatures": signature!
            ]
            
            
            try OstAPISession(userId: self.userId).authorizeSession(params: params, onSuccess: { (ostSession) in
                self.onSuccess(ostSession)
            }, onFailure: { (ostError) in
                self.onFailure(ostError)
            })
            
        }catch let error {
            self.onFailure(error as! OstError)
        }
    }
}
