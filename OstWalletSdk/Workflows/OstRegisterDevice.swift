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
        
        let indexOfDeviceValidated = orderedStates.firstIndex(of: OstWorkflowStateManager.DEVICE_VALIDATED)

        orderedStates.insert(contentsOf: inBetweenOrderedStates, at: (indexOfDeviceValidated!+1))
        return orderedStates
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstRegisterDevice.ostRegisterDeviceQueue
    }
    
    /// Process workflow
    ///
    /// - Throws: OstError
    override func process() throws {
        switch self.workflowStateManager.getCurrentState() {
        case OstRegisterDevice.DEVICE_REGISTERED:
            try onDeviceRegistered()

        default:
            try super.process()
        }
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
    
    /// Register device on params validated
    ///
    /// - Throws: OstError
    override func onDeviceValidated() throws {
        try self.initToken()
        try self.initUser()
        
        if (self.currentDevice == nil
            || self.currentDevice!.isStatusRevoked) {
          print("debug print :: onDeviceValidated :: create and register device");
            try self.createAndRegisterDevice()
            return
        }
        
        if (self.currentDevice!.isStatusCreated) {
          print("debug print :: onDeviceValidated :: register device");
            self.registerDevice(self.currentDevice!.data)
            return
        }
      
      print("debug print :: onDeviceValidated :: sync entities");
        try syncEntitesIfNeeded()
        self.postWorkflowComplete(entity: self.currentDevice!)
    }
    
    /// On device registered
    func onDeviceRegistered() throws  {
        try syncEntitesIfNeeded()
        self.postWorkflowComplete(entity: self.currentDevice!)
    }
    
    /// Verify device registered
    ///
    /// - Throws: OstError
    private func verifyDeviceRegistered() throws {
      print("debug print :: verifyDeviceRegistered :: syncing current device");
        try syncCurrentDevice()
        
        if (!self.currentDevice!.canMakeApiCall()) {
            throw OstError("w_rd_vdr_1", .deviceNotSet)
        }
    }
    
    /// Sync entities if needed. It checks for `forceSync` flag.
    ///
    /// - Throws: OstError
    private func syncEntitesIfNeeded() throws {
      print("debug print :: syncEntitesIfNeeded :: fetching entities");
        if self.forceSync {
            try self.syncEntities()
        }else {
            try ensureEntities()
        }
    }
    
    /// Sync entities from server
    ///
    /// - Throws: OstError
    private func syncEntities() throws {
        try verifyDeviceRegistered()
        try syncUser()
        try syncToken()
        if currentUser?.isStatusActivated ?? false{
            try ensureDeviceManager()
        }
    }
    
    /// Ensure that entities are persent
    ///
    /// - Throws: OstError
    private func ensureEntities() throws {
        try verifyDeviceRegistered()
        try ensureUser()
        try ensureToken()
        if currentUser?.isStatusActivated ?? false {
            try ensureDeviceManager()
        }
    }
    
    /// Creates user if user is not persent.
    ///
    /// - Throws: OstError.
    private func initUser() throws {
      print("debug print :: initUser :: initializing user");
        _  = try OstUser.initUser(forId: self.userId, withTokenId: self.tokenId)
    }
    
    /// Creates token if token is not persent.
    ///
    /// - Throws: OstError
    private func initToken() throws {
      print("debug print :: initToken :: initializing token");
        _ = try OstToken.initToken(self.tokenId)
    }
    
    /// Creates device keys and api key. Send parmeters required for register device to application.
    ///
    /// - Throws: OstError
    private func createAndRegisterDevice() throws {
      print("debug print :: createAndRegisterDevice :: creating OstKeyManager object");
        let keyManager: OstKeyManager = OstKeyManagerGateway.getOstKeyManager(userId: self.userId)
      print("debug print :: createAndRegisterDevice :: creating deviceAddress");
        let deviceAddress = try keyManager.createDeviceKey()
      print("debug print :: createAndRegisterDevice :: creating apiAddress");
        let apiAddress = try keyManager.createAPIKey()
      
      if let deviceAddressFromKeychain = OstKeyManagerGateway.getOstKeyManager(userId: self.userId).getDeviceAddress() {
        if deviceAddress.caseInsensitiveCompare(deviceAddressFromKeychain) == .orderedSame {
          print("debug print :: createAndRegisterDevice :: deviceAddress present in keychain, deviceAddress: \(deviceAddress) and deviceAddressFromKeychain: \(deviceAddressFromKeychain)");
        }else {
          print("debug print :: createAndRegisterDevice :: deviceAddressFromKeychain not equal to deviceAddress, deviceAddress: \(deviceAddress) and deviceAddressFromKeychain: \(deviceAddressFromKeychain)");
        }
      }else {
        print("debug print :: createAndRegisterDevice :: deviceAddressFromKeychain not found");
      }
      
    print("debug print :: createAndRegisterDevice :: creating apiParams");
        var apiParam: [String: Any] = [:]
        apiParam["address"] = deviceAddress
        apiParam["api_signer_address"] = apiAddress
        apiParam["updated_timestamp"] = OstUtils.toString(Date.negativeTimestamp())
        apiParam["status"] = OstUser.Status.CREATED.rawValue
        
        apiParam["user_id"] = self.userId
        _ = try OstCurrentDevice.storeEntity(apiParam)
     
      if let currentDeviceFromDB = try? OstUser.getById(self.userId)?.getCurrentDevice(),
        let cd = currentDeviceFromDB {
        print("debug print :: createAndRegisterDevice :: currentDevice present in db currentDevice: \(cd.data as AnyObject)");
      }else {
        print("debug print :: createAndRegisterDevice :: currentDevice not present in db");
      }
      
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
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .setupDevice)
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
      print("debug print :: deviceRegistered :: deviceRegistered delegate called. apiResponse: \(apiResponse as AnyObject)");
        self.performState(OstRegisterDevice.DEVICE_REGISTERED, withObject: apiResponse)
    }
}
