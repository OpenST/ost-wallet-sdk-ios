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
        case REVOKE_DEVICE = "REVOKE_DEVICE"
        case REVOKE_SESSION = "REVOKE_SESSION"
        case AUTHORIZE_DEVICE = "AUTHORIZE_DEVICE"
        case AUTHORIZE_SESSION = "AUTHORIZE_SESSION"
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
                guard let currentDevice: OstCurrentDevice = try self.getCurrentDevice() else {
                    throw OstError.invalidInput("Device is not setup. Please Setup device first. call OstSdk.setupDevice")
                }
                if (!currentDevice.isDeviceRegistered()) {
                    throw OstError.invalidInput("Device is not registered")
                }
                
                self.authenticateUser()
            }catch let error {
                self.postError(error)
            }
        }
    }

    override func processOperation() {
        do {
            self.payload = try OstUtils.toJSONObject(self.payloadString) as? [String : String]
            if (self.payload == nil) {
                self.postError(OstError.invalidInput("Invalid paylaod to process."))
            }
            self.dataDefination = (self.payload!["data_defination"]) ?? ""
            
            try self.validateParams()
            
            switch self.dataDefination {
                
            case DataDefination.AUTHORIZE_DEVICE.rawValue:
                self.authorizeDeviceWithPrivateKey()
                
            case DataDefination.REVOKE_DEVICE.rawValue:
                return
                
            case DataDefination.AUTHORIZE_SESSION.rawValue:
               return
                
            case DataDefination.REVOKE_SESSION.rawValue:
                return
                
            default:
                throw OstError.invalidInput("Invalid data defination")
            }
        }catch let error {
            self.postError(error)
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
    
    func authorizeDeviceWithPrivateKey() {
        let generateSignatureCallback: ((String) -> (String?, String?)) = { (signingHash) -> (String?, String?) in
            do {
                let keychainManager = OstKeyManager(userId: self.userId)
                if let deviceAddress = keychainManager.getDeviceAddress() {
                    //TODO: Remove Testcode - 192
                    let privatekey = try keychainManager.getEthereumKey(forAddresss: deviceAddress.lowercased())
                    //                                            return try OstCryptoImpls().signTx(signingHash, withPrivatekey: privatekey!)
                    let signature = try OstCryptoImpls().signTx(signingHash, withPrivatekey: OstConstants.testPrivateKey)
                    return (signature, deviceAddress)
                }
                throw OstError.actionFailed("issue while generating signature.")
            }catch {
                return (nil, nil)
            }
        }
        
        let onSuccess: ((OstDevice) -> Void) = { (ostDevice) in
            self.postFlowCompleteForAddDevice(entity: ostDevice)
        }
        
        let onFailure: ((OstError) -> Void) = { (error) in
            self.postError(error)
        }
        
        OstAuthorizeDevice(userId: self.userId,
                           deviceAddressToAdd: self.payload!["device_to_add"]!,
                           generateSignatureCallback: generateSignatureCallback,
                           onSuccess: onSuccess,
                           onFailure: onFailure).perform()
    }
    
    func postFlowCompleteForAddDevice(entity: OstDevice) {
        Logger.log(message: "OstAddDevice flowComplete", parameterToPrint: entity.data)
        
        DispatchQueue.main.async {
            let contextEntity: OstContextEntity = OstContextEntity(type: .addDevice , entity: entity)
            self.delegate.flowComplete(contextEntity);
        }
    }
    
}
