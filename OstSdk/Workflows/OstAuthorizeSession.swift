//
//  OstPerform+AddSession.swift
//  OstSdk
//
//  Created by aniket ayachit on 20/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAuthorizeSession: OstWorkflowBase {
    
    let abiMethodName = "authorizeSession"
    let dataDefination = OstPerform.DataDefination.AUTHORIZE_SESSION.rawValue
    let nullAddress = "0x0000000000000000000000000000000000000000"
    let workflowTransactionCountForPolling = 2

    var deviceManager: OstDeviceManager? = nil
    
    let sessionAddress: String
    let spendingLimit: String
    let expirationHeight: String
    let generateSignatureCallback: ((String) -> String?)

    init(userId: String, sessionAddress: String, spendingLimit: String, expirationHeight: String,
         generateSignatureCallback: @escaping ((String) -> String?), delegate: OstWorkFlowCallbackProtocol) {
        self.sessionAddress = sessionAddress
        self.spendingLimit = spendingLimit
        self.expirationHeight = expirationHeight
        self.generateSignatureCallback = generateSignatureCallback
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        do {
            try self.fetchDeviceManager()
        }catch let error {
            self.postError(error)
        }
    }
    
    func fetchDeviceManager() throws {
        try OstAPIDeviceManager(userId: self.userId).getDeviceManager(onSuccess: { (ostDeviceManager) in
            self.deviceManager = ostDeviceManager
            self.authorizeSession()
        }) { (ostError) in
            self.postError(ostError)
        }
    }
    
    func authorizeSession() {
        do {
            let encodedABIHex = try GnosisSafe().getAddSessionExecutableData(abiMethodName: self.abiMethodName, sessionAddress: self.sessionAddress, expirationHeight: self.expirationHeight, spendingLimit: self.spendingLimit)
            
            let user = try self.getUser()
            if (nil == user) {
                throw OstError.init("w_as_1", .userEntityNotFound)
            }
            
            self.deviceManager = try OstDeviceManager.getById(user!.deviceManagerAddress!)
            if (nil == self.deviceManager) {
                throw OstError.init("w_as_2", .deviceManagerNotFound)
            }
            
            let deviceManagerNonce = self.deviceManager!.nonce+1
            let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(to: user!.tokenHolderAddress!,
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
            
            let signature = self.generateSignatureCallback(signingHash)
            
            try self.deviceManager!.updateNonce(deviceManagerNonce)
            
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
                                         "nonce": OstUtils.toString(deviceManagerNonce),
                                         "gas_token": self.nullAddress,
                                         "refund_receiver": self.nullAddress,
                                         "signers": [user!.currentDevice!.address!],
                                         "signatures": signature!
            ]
            
            try OstAPISession(userId: self.userId).authorizeSession(params: params, onSuccess: { (ostSession) in
                self.pollingForAuthorizeSession(ostSession)
            }, onFailure: { (ostError) in
                self.postError(ostError)
            })
            
        }catch let error {
            self.postError(error)
        }
    }
    
    func pollingForAuthorizeSession(_ ostSession: OstSession) {
        
        let successCallback: ((OstSession) -> Void) = { ostSession in
            self.postFlowComplete(entity: ostSession)
        }
        
        let failuarCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        _ = OstSessionPollingService(userId: ostSession.userId!, sessionAddress: ostSession.address!, workflowTransactionCount: workflowTransactionCountForPolling, successCallback: successCallback, failuarCallback: failuarCallback).perform()
    }
    
    func postFlowComplete(entity: OstSession) {
        Logger.log(message: "OstAddSession flowComplete", parameterToPrint: entity.data)
        
        DispatchQueue.main.async {
            let contextEntity: OstContextEntity = OstContextEntity(type: .addSession , entity: entity)
            self.delegate.flowComplete(contextEntity);
        }
    }
}
