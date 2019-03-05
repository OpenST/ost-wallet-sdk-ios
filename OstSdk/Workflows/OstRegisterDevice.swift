//
//  OstRegisterDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstRegisterDevice: OstWorkflowBase, OstDeviceRegisteredProtocol {
    
    let ostRegisterDeviceQueue = DispatchQueue(label: "com.ost.sdk.OstRegisterDevice", qos: .background)
    
    var tokenId: String
    var forceSync: Bool
    var keyManager: OstKeyManager
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: Kit use id.
    ///   - tokenId: Kit token id.
    ///   - forceSync: Need to do forceSync.
    ///   - delegate: Callback.
    public init(userId: String, tokenId: String, forceSync: Bool, delegate: OstWorkFlowCallbackProtocol) {
        self.tokenId = tokenId
        self.forceSync = forceSync
        
        keyManager = OstKeyManager(userId: userId)
        
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostRegisterDeviceQueue
    }
    
    /// process workflow.
    ///
    /// - Throws: OstError
    override func process() throws {
        //init user and token
        try self.initToken()
        try self.initUser()
        
        //set user and current device
        try setUser()
        try setCurrentDevice()
        
        if (self.currentDevice == nil ||
            self.currentDevice!.isStatusRevoked ||
            self.currentDevice!.isStatusRevoking) {
            self.createAndRegisterDevice()
            return
        }
        
        if (self.currentDevice!.isStatusCreated) {
            self.registerDevice(self.currentDevice!.data)
            return
        }
        
        self.sync()
    }
    
    /// Valdiate parameters.
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        if (self.userId.isEmpty) {
            throw OstError.init("w_rd_1", .invalidUserId)
        }
        
        if (self.tokenId.isEmpty) {
            throw OstError.init("w_rd_2", .invalidTokenId)            
        }
    }
    
    /// Creates user if user is not persent.
    ///
    /// - Throws: OstError.
    func initUser() throws {
        _  = try OstUser.initUser(forId: self.userId, withTokenId: self.tokenId)
    }
    
    /// Creates token if token is not persent.
    ///
    /// - Throws: OstError
    func initToken() throws {
        _ = try OstToken.initToken(self.tokenId)
    }
    
    /// Creates device keys and api key. Send parmeters required for register device to application.
    func createAndRegisterDevice() {
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
            _ = try OstCurrentDevice.storeEntity(apiParam)
            
            apiParam["user_id"] = nil
            
            self.registerDevice(apiParam)
        }catch let error {
            self.postError(error)
        }
    }
    
    /// Get device UUID
    ///
    /// - Returns: Deice UUID is present. else nil.
    func getDeviceUUID() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    /// Get device name.
    ///
    /// - Returns: Name of device.
    func getDeviceName() -> String {
        return UIDevice.current.name
    }
    
    /// Delegate resiger device to application.
    ///
    /// - Parameter deviceParams: Register device parameters.
    func registerDevice(_ deviceParams: [String: Any]) {
        DispatchQueue.main.async {
            self.delegate.registerDevice(deviceParams, delegate: self)
        }
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
    /// Device register completion callback.
    ///
    /// - Parameter apiResponse: API response from server.
    public func deviceRegistered(_ apiResponse: [String : Any]) {
        let queue: DispatchQueue = getWorkflowQueue()
        queue.async {
            self.forceSync = true
            self.sync()
        }
    }
    
    /// Sync required entities.
    func sync() {
        let onCompletion: ((Bool) -> Void) = {isComplete in
            guard let user = try! OstUser.getById(self.userId) else {
                self.postError(OstError("w_rd_s_1", .userNotFound))
                return
            }
            guard let currentDevice = user.getCurrentDevice() else {
                self.postError(OstError("w_rd_s_2", .deviceNotFound))
                return
            }
            do {
                let device:OstDevice = try OstDevice.getById(currentDevice.address!)!;
                self.postWorkflowComplete(entity: device);
            } catch let err {
                self.postError(err as! OstError);
            }
        }
        OstSdkSync(userId: self.userId, forceSync: self.forceSync, syncEntites: .User, .CurrentDevice, .Token, onCompletion: onCompletion).perform()
    }
}
