//
//  OstPerform.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstPerform: OstWorkflowBase {
    let ostPerformThread = DispatchQueue(label: "com.ost.sdk.OstPerform", qos: .background)
    
    enum DataDefination: String {
        case AUTHORIZE_DEVICE = "AUTHORIZE_DEVICE"
        case REVOKE_DEVICE = "REVOKE_DEVICE"
        case AUTHORIZE_SESSION = "AUTHORIZE_SESSION"
        case REVOKE_SESSION = "REVOKE_SESSION"
    }
    
    let multiSigDataString: String
    
    var dataDefination: String? = nil
    var multiSigDict: [String: Any]? = nil
    var deviceManager: OstDeviceManager? = nil
    
    init(userId: String, multiSigDataString: String, delegate: OstWorkFlowCallbackProtocol) {
        self.multiSigDataString = multiSigDataString
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        ostPerformThread.async {
            do {
                self.multiSigDict = try OstUtils.toJSONObject(self.multiSigDataString) as? [String : Any]
                self.dataDefination = (self.multiSigDict!["data_defination"]) as? String
                
                try self.validateParams()
                
                let onDeviceManagerFetchCallback: ((Bool) -> Void) = { isSuccess in
                    if (isSuccess) {
                        do {
                            switch self.dataDefination {
                            case DataDefination.AUTHORIZE_DEVICE.rawValue:
                                try self.authorizeDevice()
                            case DataDefination.REVOKE_DEVICE.rawValue:
                                ""
                            case DataDefination.AUTHORIZE_SESSION.rawValue:
                                ""
                            case DataDefination.REVOKE_SESSION.rawValue:
                                ""
                            default:
                                throw OstError.invalidInput("Invalid data defination")
                            }
                        }catch let error {
                            self.postError(error)
                        }
                    }else {
                        self.postError(OstError.actionFailed("Fetching device manager failed."))
                    }
                }
                
                try self.fetchDeviceManager(onCompletion: onDeviceManagerFetchCallback)
                
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    func validateParams() throws {
        switch self.dataDefination {
        case DataDefination.AUTHORIZE_DEVICE.rawValue:
            return
        case DataDefination.REVOKE_DEVICE.rawValue:
            return
        case DataDefination.AUTHORIZE_SESSION.rawValue:
            return
        case DataDefination.REVOKE_SESSION.rawValue:
            return
        default:
            throw OstError.invalidInput("Invalid data defination.")
        }
    }

    func fetchDeviceManager(onCompletion: @escaping ((Bool) -> Void)) throws {
        try OstAPIDeviceManager(userId: self.userId).getDeviceManager(onSuccess: { (ostDeviceManager) in
            self.deviceManager = ostDeviceManager
            onCompletion(true)
        }) { (ostError) in
            onCompletion(false )
        }
    }
    
    func authorizeDevice() throws {
        let parameters: [Any] = self.multiSigDict!["parameters"] as! [Any]
        let encodedABIHex = try GnosisSafe().getAddOwnerWithThresholdExecutableData(ownerAddress: parameters[0] as! String, threshold: OstUtils.toString(parameters[1])!)
        
        let deviceManagerNonce: Int = self.deviceManager!.nonce+1
        let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(to: OstUtils.toString(self.multiSigDict!["to"])!,
                                                          value: OstUtils.toString(self.multiSigDict!["value"])!,
                                                          data: encodedABIHex,
                                                          operation: OstUtils.toString(self.multiSigDict!["operation"])!,
                                                          safeTxGas: OstUtils.toString(self.multiSigDict!["safe_tx_gas"])!,
                                                          dataGas: OstUtils.toString(self.multiSigDict!["data_gas"])!,
                                                          gasPrice: OstUtils.toString(self.multiSigDict!["gas_price"])!,
                                                          gasToken: OstUtils.toString(self.multiSigDict!["gas_token"])!,
                                                          refundReceiver: OstUtils.toString(self.multiSigDict!["refund_receiver"])!,
                                                          nonce: OstUtils.toString(deviceManagerNonce)! )
        
        let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any], primaryType: typedDataInput["primaryType"] as! String, domain: typedDataInput["domain"] as! [String: String], message: typedDataInput["message"] as! [String: Any])
        let signingHash = try! eip712.getEIP712SignHash()
        
        try self.deviceManager!.updateNonce(deviceManagerNonce)
     
        let user: OstUser = try self.getUser()!
        self.multiSigDict!["signer"] =  user.currentDevice!.address!
        self.multiSigDict!["signature"] = signingHash
        
        try OstAPIDevice(userId: self.userId).authorizeDevice(params: self.multiSigDict!, onSuccess: { (ostDevice) in
            self.postFlowComplete(entity: ostDevice)
        }) { (error) in
            self.postError(error)
        }
    }
    
    func postFlowComplete(entity: OstDevice) {
        Logger.log(message: "OstActivateUser flowComplete", parameterToPrint: entity.data)
        
        DispatchQueue.main.async {
            let contextEntity: OstContextEntity = OstContextEntity(type: .activateUser , entity: entity)
            self.delegate.flowComplete(contextEntity);
        }
    }
}
