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
    
    let payloadString: String
    
    var dataDefination: String? = nil
    var payload: [String: String]? = nil
    var deviceManager: OstDeviceManager? = nil
    
    let threshold = "1"
    let nullAddress = "0x0000000000000000000000000000000000000000"
    
    init(userId: String, payload: String, delegate: OstWorkFlowCallbackProtocol) {
        self.payloadString = payload
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        ostPerformThread.async {
            do {
                self.payload = try OstUtils.toJSONObject(self.payloadString) as? [String : String]
                if (self.payload == nil) {
                    self.postError(OstError.invalidInput("Invalid QR-Code."))
                }
                self.dataDefination = (self.payload!["data_defination"]) as? String
                
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
            guard let _ = self.payload!["user_id"] else {
                throw OstError.invalidInput("User id is not present.")
            }
            guard let _ = self.payload!["device_to_add"] else {
                throw OstError.invalidInput("Device to add is not persent")
            }
            
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
        
        let deviceAddressToAdd = self.payload!["device_to_add"]
        
        
        
        let encodedABIHex = try GnosisSafe().getAddOwnerWithThresholdExecutableData(ownerAddress: deviceAddressToAdd!, threshold: threshold)
        
        let deviceManagerNonce: Int = self.deviceManager!.nonce+1
        let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(to: self.deviceManager!.address!,
                                                                           value: "0",
                                                                           data: encodedABIHex,
                                                                           operation: "0",
                                                                           safeTxGas: "0",
                                                                           dataGas: "0",
                                                                           gasPrice: "0",
                                                                           gasToken: self.nullAddress,
                                                                           refundReceiver: self.nullAddress,
                                                                           nonce: OstUtils.toString(deviceManagerNonce)!)
        
        let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any], primaryType: typedDataInput["primaryType"] as! String, domain: typedDataInput["domain"] as! [String: String], message: typedDataInput["message"] as! [String: Any])
        let signingHash = try! eip712.getEIP712SignHash()
        
        try self.deviceManager!.updateNonce(deviceManagerNonce)
     
        let user: OstUser = try self.getUser()!
        self.payload!["signer"] =  user.currentDevice!.address!
        self.payload!["signature"] = signingHash
        
        try OstAPIDevice(userId: self.userId).authorizeDevice(params: self.payload!, onSuccess: { (ostDevice) in
            self.postFlowComplete(entity: ostDevice)
        }) { (error) in
            self.postError(error)
        }
    }
    
    
    func getDevice(forAddress: String) {
        
    }
    
    func postFlowComplete(entity: OstDevice) {
        Logger.log(message: "OstActivateUser flowComplete", parameterToPrint: entity.data)
        
        DispatchQueue.main.async {
            let contextEntity: OstContextEntity = OstContextEntity(type: .activateUser , entity: entity)
            self.delegate.flowComplete(contextEntity);
        }
    }
}
