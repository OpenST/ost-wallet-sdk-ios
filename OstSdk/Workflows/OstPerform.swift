//
//  OstPerform.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstPerform: OstWorkflowBase, OstPinAcceptProtocol {
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
    
    var saltResponse: [String: Any]? = nil
    var uPin: String? = nil
    var password: String? = nil
    
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
                    throw OstError.init("w_p_p_1", .deviceNotset)
                }
                if (!currentDevice.isDeviceRegistered()) {
                    throw OstError.init("w_p_p_2", .deviceNotRegistered)
                }
                
                self.processOperation()
            }catch let error {
                self.postError(error)
            }
        }
    }

    func processOperation() {
        do {
            self.payload = try OstUtils.toJSONObject(self.payloadString) as? [String : String]
            if (self.payload == nil) {
                self.postError(OstError.init("w_p_po_1", .invalidPayload))
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
                throw OstError.init("w_o_po_1", .invalidDataDefination)
            }
        }catch let error {
            self.postError(error)
        }
    }
    
    func validateParams() throws {
        switch self.dataDefination {
            
        case DataDefination.AUTHORIZE_DEVICE.rawValue:
            guard let _ = self.payload!["user_id"] else {
                throw OstError.init("w_p_vp_1", .userEntityNotFound)
            }
            guard let _ = self.payload!["device_to_add"] else {
                throw OstError.init("w_p_vp_2", .deviceNotFound)
            }
            
        case DataDefination.REVOKE_DEVICE.rawValue:
            return
            
        case DataDefination.AUTHORIZE_SESSION.rawValue:
            return
            
        case DataDefination.REVOKE_SESSION.rawValue:
            return
            
        default:
            throw OstError.init("w_p_vp_3", .invalidDataDefination)
        }
    }
    
    public func authenticateUser() {
        let biomatricAuth: BiometricIDAuth = BiometricIDAuth()
        biomatricAuth.authenticateUser { (isSuccess, message) in
            if (isSuccess) {
                do {
                 self.processOperation()
                }catch let error{
                    self.postError(error)
                }
            }else {
                DispatchQueue.main.async {
                    self.delegate.getPin(self.userId, delegate: self)
                }
            }
        }
    }
    
    //MARK - OstPinAcceptProtocol
    
    func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        ostPerformThread.async {
            do {
                self.uPin = uPin
                self.password = appUserPassword
                if (self.saltResponse != nil) {
                    try self.validatePin()
                }else {
                    try OstAPISalt(userId: self.userId).getRecoverykeySalt(onSuccess: { (saltResponse) in
                        do {
                            self.saltResponse = saltResponse
                            try self.validatePin()
                        }catch let error {
                            self.postError(error)
                        }
                        
                    }, onFailure: { (error) in
                        self.postError(error)
                    })
                }

            }catch let error {
                self.postError(error)
            }
        }
    }
    func validatePin() throws {
        let salt = self.saltResponse!["scrypt_salt"] as! String
        let recoveryKey = try OstCryptoImpls().generateRecoveryKey(password: self.password!, pin: self.uPin!, userId: self.userId,
                                                                   salt: salt,  n: OstConstants.OST_RECOVERY_PIN_SCRYPT_N,
                                                                   r: OstConstants.OST_RECOVERY_PIN_SCRYPT_R,
                                                                   p: OstConstants.OST_RECOVERY_PIN_SCRYPT_P,
                                                                   size: OstConstants.OST_RECOVERY_PIN_SCRYPT_DESIRED_SIZE_BYTES)
        
        guard let user: OstUser = try getUser() else {
            throw OstError.init("w_p_vp_1", .userEntityNotFound)
        }
        
        if (user.recoveryAddress == nil || user.recoveryAddress!.isEmpty) {
            throw OstError.init("w_p_vp_2", .recoveryAddressNotFound)        
        }
        
        if(user.recoveryAddress! == recoveryKey) {
            self.processOperation()
        }else {
            DispatchQueue.main.async {
                self.delegate.invalidPin(self.userId, delegate: self)
            }
        }
        
    }
    
    func authorizeDeviceWithPrivateKey() {
        let generateSignatureCallback: ((String) -> (String?, String?)) = { (signingHash) -> (String?, String?) in
            do {
                let keychainManager = OstKeyManager(userId: self.userId)
                if let deviceAddress = keychainManager.getDeviceAddress() {
                    //TODO: Remove Testcode - 192
                    let privatekey = try keychainManager.getDeviceKey()
                    //                                            return try OstCryptoImpls().signTx(signingHash, withPrivatekey: privatekey!)
                    let signature = try OstCryptoImpls().signTx(signingHash, withPrivatekey: OstConstants.testPrivateKey)
                    return (signature, deviceAddress)
                }
                throw OstError.init("w_p_adwp_1", .signatureGenerationFailed)
            }catch let error {
                self.postError(error)
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
