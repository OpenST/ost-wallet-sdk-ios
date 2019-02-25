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
    
    var tokenId: String
    var forceSync: Bool
    var keyManager: OstKeyManager
    
    public init(userId: String, tokenId: String, forceSync: Bool, delegat: OstWorkFlowCallbackProtocol) {
        self.tokenId = tokenId
        self.forceSync = forceSync
        
        keyManager = OstKeyManager(userId: userId)
        
        super.init(userId: userId, delegate: delegat)
    }
    
    override func perform() {
        ostRegisterDeviceThread.async {
            do {
                try self.validateParams()

                try self.initToken()
                try self.initUser()
                
                let currentDevice = try self.getCurrentDevice()
                if (currentDevice == nil || currentDevice!.isDeviceRevoked()) {
                    self.createAndRegisterDevice()
                    return
                }
                
                if(!currentDevice!.isDeviceRegistered()) {
                    self.registerDevice(currentDevice!.data as [String : Any])
                    return
                }
            
                self.forceSync = true
                self.sync()
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    func validateParams() throws {
        if (self.userId.isEmpty) {
            throw OstError.invalidInput("userId should not be empty string.")
        }
        
        if (self.tokenId.isEmpty) {
            throw OstError.invalidInput("tokenId should not be empty string.")
        }
    }
    
    func initUser() throws {
        _  = try OstSdk.initUser(forId: self.userId, withTokenId: self.tokenId)
    }
    
    func initToken() throws {
        _ = try OstSdk.initToken(self.tokenId)
    }
    
    func createAndRegisterDevice() {
        DispatchQueue.main.async {
            do {
                let deviceAddress = try self.keyManager.createDeviceKey()
                let apiAddress = try self.keyManager.createAPIKey()
                
                var apiParam: [String: Any] = [:]
                apiParam["address"] = deviceAddress
                apiParam["api_signer_address"] = apiAddress
                apiParam["device_uuid"] = self.getDeviceUUID() ?? ""
                apiParam["device_name"] = self.getDeviceName()
                apiParam["updated_timestamp"] = OstUtils.toString(Date.negativeTimestamp())
                apiParam["status"] = OstUser.Status.CREATED.rawValue
               
                apiParam["user_id"] = self.userId
                _ = try OstCurrentDevice.parse(apiParam)
                
                apiParam["user_id"] = nil
                
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
    
    func registerDevice(_ deviceParams: [String: Any]) {
        DispatchQueue.main.async {
            self.delegate.registerDevice(deviceParams, delegate: self)
        }
    }
    
    func sync() {
        let onCompletion: ((Bool) -> Void) = {isComplete in
            guard let user = try! OstUser.getById(self.userId) else {
                self.postError(OstError1("w_rd_s_1", .userNotFound))
                return
            }
            self.postWorkflowComplete(entity: user.getCurrentDevice()!)
        }
        OstSdkSync(userId: self.userId, forceSync: self.forceSync, syncEntites: .User, .CurrentDevice, .Token, onCompletion: onCompletion).perform()
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
         return OstWorkflowContext(workflowType: .setupDevice)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
    
    //MARK: - OstDeviceRegisteredProtocol
    public func deviceRegistered(_ apiResponse: [String : Any]) throws {
        self.forceSync = true
        sync()
    }
}
