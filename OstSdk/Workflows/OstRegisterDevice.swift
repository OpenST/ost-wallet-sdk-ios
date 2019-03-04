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
    
    public init(userId: String, tokenId: String, forceSync: Bool, delegate: OstWorkFlowCallbackProtocol) {
        self.tokenId = tokenId
        self.forceSync = forceSync
        
        keyManager = OstKeyManager(userId: userId)
        
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        ostRegisterDeviceThread.async {
            do {
                try self.validateParams()

                try self.initToken()
                try self.initUser()
                
                let currentDevice = try self.getCurrentDevice()
                if (currentDevice == nil ||
                    currentDevice!.isStatusRevoked ||
                    currentDevice!.isStatusRevoking) {
                    self.createAndRegisterDevice()
                    return
                }
                
                if(currentDevice!.isStatusRegistered) {
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
            throw OstError.init("w_rd_1", .invalidUserId)
        }
        
        if (self.tokenId.isEmpty) {
            throw OstError.init("w_rd_2", .invalidTokenId)            
        }
    }
    
    func initUser() throws {
        _  = try OstUser.initUser(forId: self.userId, withTokenId: self.tokenId)
    }
    
    func initToken() throws {
        _ = try OstToken.initToken(self.tokenId)
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
                _ = try OstCurrentDevice.storeEntity(apiParam)
                
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
        //To-Do: Remove this code after fixing the bug.
        //Bug Description: The device status never changes to 'Registered' as the local data never changes.
        //As all API calls (including sync api call) fail because deivce is still in 'Created'.
        //Workaround: God bless the parse Api :p :p :p
        //_ = try OstDevice.parse(apiResponse);
        self.forceSync = true
        sync()
    }
}
