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
                    throw OstError.init("w_p_p_1", .deviceNotset)
                }
                if (!currentDevice.isDeviceRegistered()) {
                    throw OstError.init("w_p_p_2", .deviceNotRegistered)
                }
                
                self.authenticateUser()
            }catch let error {
                self.postError(error)
            }
        }
    }

    override func proceedWorkflowAfterAuthenticateUser() {
        do {
            self.payload = try OstUtils.toJSONObject(self.payloadString) as? [String : String]
            if (self.payload == nil) {
                self.postError(OstError.init("w_p_po_1", .invalidPayload))
            }
            self.dataDefination = (self.payload!["data_defination"])?.uppercased() ?? ""
            
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
            guard let _ = self.payload!["device_address"] else {
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

    func authorizeDeviceWithPrivateKey() {
        let generateSignatureCallback: ((String) -> (String?, String?)) = { (signingHash) -> (String?, String?) in
            do {
                let keychainManager = OstKeyManager(userId: self.userId)
                if let deviceAddress = keychainManager.getDeviceAddress() {
                    //TODO: Remove Testcode - 192
                    let privatekey = try keychainManager.getDeviceKey()
                    let signature = try OstCryptoImpls().signTx(signingHash, withPrivatekey: privatekey!)
                    return (signature, deviceAddress)
                }
                throw OstError.init("w_p_adwp_1", .signatureGenerationFailed)
            }catch {
                return (nil, nil)
            }
        }
        
        let onSuccess: ((OstDevice) -> Void) = { (ostDevice) in
            self.postWorkflowComplete(entity: ostDevice)
        }
        
        let onFailure: ((OstError) -> Void) = { (error) in
            self.postError(error)
        }
        
        OstAuthorizeDevice(userId: self.userId,
                           deviceAddressToAdd: self.payload!["device_address"]!,
                           generateSignatureCallback: generateSignatureCallback,
                           onSuccess: onSuccess,
                           onFailure: onFailure).perform()
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .perform)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
    
}
