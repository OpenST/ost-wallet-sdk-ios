//
//  OstRegisterDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstRegisterDevice: OstWorkflowBase, OstDeviceRegisteredProtocol {
    
    let ostRegisterDeviceThread = DispatchQueue(label: "com.ost.sdk.OstRegisterDevice", qos: .background)
    var delegate: OstWorkFlowCallbackProtocol
    var keyManager: OstKeyManager
    var tokenId: String
    var forceSync: Bool
    
    public init(userId: String, tokenId: String, forceSync: Bool, delegat: OstWorkFlowCallbackProtocol) throws {
        self.tokenId = tokenId
        self.delegate = delegat
        self.forceSync = forceSync
        
        keyManager = try OstKeyManager(userId: userId)
        
        super.init(userId: userId)
    }
    
    override func perform() {
        ostRegisterDeviceThread.async {
            do {
                let (isValidParams, errorMessage) = self.isValidParams()
                if (!isValidParams) {
                    self.postError(OstError.invalidInput(errorMessage))
                    return
                }
                
                try self.initToken()
                try self.initUser()
                
                let currentDevice = try self.getCurrentDevice()
                if (currentDevice == nil || currentDevice!.isDeviceRevoked()) {
                    self.createAndRegisterDevice()
                    return
                }
                
                if(!currentDevice!.isDeviceRegistered()) {
                    self.registerDevice(currentDevice!.data as [String : Any])
                }
            
                self.sync()
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    func isValidParams() -> (Bool, String?) {
        if (self.userId.isEmpty) {
            return (false, "userId should not be empty string.")
        }
        
        if (self.tokenId.isEmpty) {
            return (false, "tokenId should not be empty string.")
        }
        
        return (true, nil)
    }
    
    func initUser() throws {
        _  = try OstSdk.initUser(forId: self.userId, withTokenId: self.tokenId)
    }
    
    func initToken() throws {
        _ = try OstSdk.initToken(self.tokenId)
    }
    
    func postFlowComplete(entity: OstCurrentDevice) {
        Logger.log(message: "flowComplete", parameterToPrint: nil)
        DispatchQueue.main.async {
            let contextEntity: OstContextEntity = OstContextEntity(type: .registerDevice , entity: entity)
            self.delegate.flowComplete(contextEntity);
        }
    }
    
    func postError(_ error: Error) {
        DispatchQueue.main.async {
            self.delegate.flowInterrupt(error as! OstError)
        }
    }
    
    func registerDevice(_ deviceParams: [String: Any]) {
        DispatchQueue.main.async {
            self.delegate.registerDevice(deviceParams, delegate: self)
        }
    }
    
    func createAndRegisterDevice() {
        DispatchQueue.main.async {
            do {
                let deviceAddress = try self.keyManager.createKeyWithMnemonics()
                let apiAddress = try self.keyManager.createAPIKey()
                
                var apiParam: [String: Any] = [:]
                apiParam["address"] = deviceAddress
                apiParam["api_signer_address"] = apiAddress
                apiParam["device_uuid"] = self.getDeviceUUID() ?? ""
                apiParam["device_name"] = self.getDeviceName()
                apiParam["updated_timestamp"] = OstUtils.toString(Date.negativeTimestamp())
                apiParam["status"] = "CREATED"
                
                _ = try OstCurrentDevice.parse(apiParam)
                
                self.registerDevice(apiParam)
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    func getDeviceUUID() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    func getDeviceName() -> String {
        return UIDevice.current.name
    }
    
    func sync() {
        let onCompletion: ((Bool) -> Void) = {_ in
            self.delegate.flowComplete(OstContextEntity(type: .registerDevice))
        }
        
        OstSdkSync(userId: self.userId, forceSync: self.forceSync, syncEntites:.User, .Token, onCompletion: onCompletion).perform()
    }
    
    //MARK: - OstDeviceRegisteredProtocol
    public func deviceRegistered(_ apiResponse: [String : Any]) throws {
        if let deviceJSON = apiResponse["device"] as? [String : Any] {
            _ = try OstDevice.parse(deviceJSON)
            sync()
        }else {
            delegate.flowInterrupt(OstError.invalidInput("api response is not as desired."))
        }
        
    }
    
    public func cancelFlow(_ cancelReason: String) {
        
    }
    
}
