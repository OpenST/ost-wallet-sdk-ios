/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstRegisterDevice: OstWorkflowEngine, OstDeviceRegisteredDelegate {
    
    static let DEVICE_REGISTERED = "DEVICE_REGISTERED"
    
    static private let ostRegisterDeviceQueue = DispatchQueue(label: "com.ost.sdk.OstRegisterDevice", qos: .background)
    private let tokenId: String
    private var forceSync: Bool
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - tokenId: Token id
    ///   - forceSync: Should sync entities
    ///   - delegate: Callback
    init(userId: String,
         tokenId: String,
         forceSync: Bool,
         delegate: OstWorkflowDelegate) {
        
        self.tokenId = tokenId
        self.forceSync = forceSync            
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Sets in ordered states for current Workflow
    ///
    /// - Returns: Order states array
    override func getOrderedStates() -> [String] {
        var orderedStates:[String] = super.getOrderedStates()
        
        var inBetweenOrderedStates = [String]()
        inBetweenOrderedStates.append(OstRegisterDevice.DEVICE_REGISTERED)
        
        orderedStates.insert(contentsOf:inBetweenOrderedStates, at:3)
        return orderedStates
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstRegisterDevice.ostRegisterDeviceQueue
    }
    
    /// Valdiate parameters.
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        if (self.userId.isEmpty) {
            throw OstError("w_rd_1", .invalidUserId)
        }
        
        if (self.tokenId.isEmpty) {
            throw OstError("w_rd_2", .invalidTokenId)
        }
    }

    /// Perform user device validation
    ///
    /// - Throws: OstError
    override func performUserDeviceValidation() throws {
        //Exceptional case.
    }
     
    /// Process workflow
    ///
    /// - Throws: OstError
    override func process() throws {
        switch self.workflowStateManager.getCurrentState() {
        case OstRegisterDevice.DEVICE_REGISTERED:
            self.forceSync = true
            sync()
            
        default:
            try super.process()
        }
    }
    
    /// Register device on params validated
    ///
    /// - Throws: OstError
    override func onDeviceValidated() throws {
        try self.initToken()
        try self.initUser()
        
        if (self.currentDevice == nil
            || self.currentDevice!.isStatusRevoked) {
            try self.createAndRegisterDevice()
            return
        }
        
        if (self.currentDevice!.isStatusCreated) {
            self.registerDevice(self.currentDevice!.data)
            return
        }
        
        try self.processNext()
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
    ///
    /// - Throws: OstError
    private func createAndRegisterDevice() throws {
        
        let keyManager: OstKeyManager = OstKeyManagerGateway.getOstKeyManager(userId: self.userId)
        let deviceAddress = try keyManager.createDeviceKey()
        let apiAddress = try keyManager.createAPIKey()
        
        var apiParam: [String: Any] = [:]
        apiParam["address"] = deviceAddress
        apiParam["api_signer_address"] = apiAddress
        apiParam["updated_timestamp"] = OstUtils.toString(Date.negativeTimestamp())
        apiParam["status"] = OstUser.Status.CREATED.rawValue
        
        apiParam["user_id"] = self.userId
        _ = try OstCurrentDevice.storeEntity(apiParam)
        
        apiParam["user_id"] = nil
        
        self.registerDevice(apiParam)
    }
    
    /// Delegate resiger device to application.
    ///
    /// - Parameter deviceParams: Register device parameters.
    private func registerDevice(_ deviceParams: [String: Any]) {
        DispatchQueue.main.async {
            self.delegate?.registerDevice(deviceParams, delegate: self)
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
        self.performNext(withObject: apiResponse)
    }
    
    /// Sync required entities.
    private func sync() {
        let onCompletion: ((Bool) -> Void) = {isComplete in
            guard let user = try! OstUser.getById(self.userId) else {
                self.postError(OstError("w_rd_s_1", .userNotFound))
                return
            }
            guard let currentDevice = user.getCurrentDevice() else {
                self.postError(OstError("w_rd_s_2", .deviceNotSet))
                return
            }
            do {
                let device:OstDevice = try OstDevice.getById(currentDevice.address!)!
                self.postWorkflowComplete(entity: device)
            } catch let err {
                self.postError(err as! OstError);
            }
        }
        OstSdkSync(userId: self.userId, forceSync: self.forceSync, syncEntites: .User, .CurrentDevice, .Token, onCompletion: onCompletion).perform()
    }
}
