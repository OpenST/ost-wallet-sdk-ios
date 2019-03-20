/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstRegisterDevice: OstWorkflowBase, OstDeviceRegisteredDelegate {
    static private let ostRegisterDeviceQueue = DispatchQueue(label: "com.ost.sdk.OstRegisterDevice", qos: .background)
    private let tokenId: String
    private var forceSync: Bool
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: Kit use id.
    ///   - tokenId: Kit token id.
    ///   - forceSync: Need to do forceSync.
    ///   - delegate: Callback.
    init(userId: String,
         tokenId: String,
         forceSync: Bool,
         delegate: OstWorkflowDelegate) {
        
        self.tokenId = tokenId
        self.forceSync = forceSync            
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstRegisterDevice.ostRegisterDeviceQueue
    }
    
    /// Perform any tasks that are prerequisite for the workflow,
    /// this is called before validateParams() and process()
    ///
    /// - Throws: OstError
    override func beforeProcess() throws {
        //init user and token
        try self.initToken()
        try self.initUser()
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
    
    /// process workflow.
    ///
    /// - Throws: OstError
    override func process() throws {
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
    
    /// Creates user if user is not persent.
    ///
    /// - Throws: OstError.
    private func initUser() throws {
        _  = try OstUser.initUser(forId: self.userId, withTokenId: self.tokenId)
    }
    
    /// Creates token if token is not persent.
    ///
    /// - Throws: OstError
    private func initToken() throws {
        _ = try OstToken.initToken(self.tokenId)
    }
    
    /// Creates device keys and api key. Send parmeters required for register device to application.
    private func createAndRegisterDevice() {
        do {
            let keyManager = OstKeyManager(userId: self.userId)
            let deviceAddress = try keyManager.createDeviceKey()
            let apiAddress = try keyManager.createAPIKey()
            
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
    private func getDeviceUUID() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    /// Get device name.
    ///
    /// - Returns: Name of device.
    private func getDeviceName() -> String {
        return UIDevice.current.name
    }
    
    /// Delegate resiger device to application.
    ///
    /// - Parameter deviceParams: Register device parameters.
    private func registerDevice(_ deviceParams: [String: Any]) {
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
    private func sync() {
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
