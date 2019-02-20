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
                
                try self.fetchDeviceManager()
                
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    func fetchDeviceManager() throws {
        try OstAPIDeviceManager(userId: self.userId).getDeviceManager(onSuccess: { (ostDeviceManager) in
            self.deviceManager = ostDeviceManager
            self.processOperation()
        }) { (ostError) in
            self.postError(ostError)
        }
    }
    
    func processOperation() {
        do {
            self.payload = try OstUtils.toJSONObject(self.payloadString) as? [String : String]
            if (self.payload == nil) {
                self.postError(OstError.invalidInput("Invalid paylaod to process."))
            }
            self.dataDefination = (self.payload!["data_defination"]) ?? ""
            
            try self.validateParams()
            
            switch self.dataDefination {
                
            case DataDefination.AUTHORIZE_DEVICE.rawValue:
                try self.getDevice() //Written in extention - OstPerform+AddDevice
                
            case DataDefination.REVOKE_DEVICE.rawValue:
                return
                
            case DataDefination.AUTHORIZE_SESSION.rawValue:
                try self.authorizeSession() //Written in extension - OstProfrom+AddSession
                
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
    
    func authorizeUser() {
        let biomatricAuth: 
    }
}
