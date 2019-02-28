//
//  OstAddSession.swift
//  OstSdk
//
//  Created by aniket ayachit on 19/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAddSession: OstWorkflowBase {
    static let SESSION_BUFFER_TIME = Double.init(1 * 60 * 60); //1 Hour.
  
    let ostAddSessionThread = DispatchQueue(label: "com.ost.sdk.OstAddSession", qos: .background)
    let workflowTransactionCountForPolling = 1
    
    var spendingLimit: String
    var expirationHeight: Int?
    var expiresAfter: TimeInterval;
    
    var user: OstUser? = nil
    var currentDevice: OstCurrentDevice? = nil
    var sessionAddress: String? = nil
    var chainInfo: [String: Any]? = nil
  

    init(userId: String, spendingLimit: String, expiresAfter: TimeInterval, delegate: OstWorkFlowCallbackProtocol) {
        self.spendingLimit = spendingLimit
        self.expiresAfter = expiresAfter;
        super.init(userId: userId, delegate: delegate)
    }
  
    override func perform() {
        ostAddSessionThread.async {
            do {
                try self.valdiateParams()
                self.generateSessionKeys()
                self.getCurrentBlockHeight()
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    func valdiateParams() throws {
        self.user = try getUser()
        if (nil == self.user) {
            throw OstError("w_as_vp_1", .userNotFound)
        }
        if (!self.user!.isStatusActivated) {
            throw OstError("w_as_vp_1", .userNotActivated)
        }
        
        self.currentDevice = try getCurrentDevice()
        if (nil == self.currentDevice) {
            throw OstError("w_as_vp_2", .deviceNotFound);
        }
        if (!self.currentDevice!.isStatusAuthorized) {
            throw OstError("w_as_vp_3", .deviceNotAuthorized)
        }
    }
    
    func generateSessionKeys() {
        do {
            let keyMananger = OstKeyManager(userId: self.userId)
            self.sessionAddress = try keyMananger.createSessionKey()
        }catch let error {
            self.postError(error)
        }
    }
    
    func getCurrentBlockHeight() {
        do {
            let onSuccess: (([String: Any]) -> Void) = { chainInfo in
                self.chainInfo = chainInfo
                self.authorizeSession()
            }
            
            let onFailuar: ((OstError) -> Void) = { error in
                self.postError(error)
            }
            
            _ = try OstAPIChain(userId: self.userId).getChain(onSuccess: onSuccess, onFailure: onFailuar)
        }catch let error {
            self.postError(error)
        }
    }
    
    func authorizeSession() {
        let generateSignatureCallback: ((String) -> (String?, String?)) = { (signingHash) -> (String?, String?) in
            do {
                let keychainManager = OstKeyManager(userId: self.userId)
                if let deviceAddress = keychainManager.getDeviceAddress() {
                    let signature = try keychainManager.signWithDeviceKey(signingHash)
                    return (signature, deviceAddress)
                }
                throw OstError("w_as_as_1", .signatureGenerationFailed)
            }catch {
                return (nil, nil)
            }
        }
        
        let onSuccess: ((OstSession) -> Void) = { (ostSession) in
            self.postRequestAcknowledged(entity: ostSession)
            self.pollingForAuthorizeSession(ostSession)
        }
        
        let onFailure: ((OstError) -> Void) = { (error) in
            Logger.log(message: "I am here - OstAddSession");
            self.postError(error)
        }
      
        // Calculate expiration height
        let currentBlockHeight = OstUtils.toInt(self.chainInfo!["block_height"])!;
        let blockGenerationTime = OstUtils.toInt(self.chainInfo!["block_time"])!;
        let bufferedSessionTime = OstAddSession.SESSION_BUFFER_TIME + self.expiresAfter;
        let validForBlocks = Int.init( bufferedSessionTime/Double(blockGenerationTime) );
        self.expirationHeight = validForBlocks + currentBlockHeight;
      
        self.generateAndSaveSessionEntity()
     
        OstAuthorizeSession(userId: self.userId,
                            sessionAddress: self.sessionAddress!,
                            spendingLimit: self.spendingLimit,
                            expirationHeight: OstUtils.toString(self.expirationHeight!)!,
                            generateSignatureCallback: generateSignatureCallback,
                            onSuccess: onSuccess,
                            onFailure: onFailure).perform()
    }
    
    func generateAndSaveSessionEntity() {
        do {
            let params = self.getSessionEnityParams()
            try OstSession.storeEntity(params)
        }catch let error {
            self.postError(error)
        }
    }
    
    func getSessionEnityParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["user_id"] = self.userId
        params["address"] = self.sessionAddress!
        params["expiration_height"] = self.expirationHeight!
        params["spending_limit"] = self.spendingLimit
        params["nonce"] = 0
        params["status"] = OstSession.Status.CREATED.rawValue
        
        return params
    }
    
    func pollingForAuthorizeSession(_ ostSession: OstSession) {
        
        let successCallback: ((OstSession) -> Void) = { ostSession in
            self.postWorkflowComplete(entity: ostSession)
        }
        
        let failuarCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstSessionPollingService(userId: ostSession.userId!,
                                 sessionAddress: ostSession.address!,
                                 workflowTransactionCount: workflowTransactionCountForPolling,
                                 successCallback: successCallback, failuarCallback: failuarCallback).perform()
    }

    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .addSession)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .session)
    }
}
