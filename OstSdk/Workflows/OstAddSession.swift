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
//    var expirationHeight: Int?
    var expiresAfter: TimeInterval;
    
    var sessionHelper: OstSessionHelper.SessionHelper? = nil

//    var sessionAddress: String? = nil
    var chainInfo: [String: Any]? = nil
  
    init(userId: String, spendingLimit: String, expiresAfter: TimeInterval, delegate: OstWorkFlowCallbackProtocol) {
        self.spendingLimit = spendingLimit
        self.expiresAfter = expiresAfter;
        super.init(userId: userId, delegate: delegate)
    }
  
    override func perform() {
        ostAddSessionThread.async {
            do {
                try self.validateParams()
//                self.generateSessionKeys()
//                self.getCurrentBlockHeight()
                
                OstSessionHelper(userId: self.userId, expiresAfter: self.expiresAfter)
                    .getSessionData(onSuccess: { (sessionHelper) in
                        self.sessionHelper = sessionHelper
                        self.authorizeSession()
                    }, onFailure: { (error) in
                        self.postError(error)
                    })
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    func validateParams() throws {
        self.currentUser = try getUser()
        if (nil == self.currentUser) {
            throw OstError("w_as_vp_1", .userNotFound)
        }
        if (!self.currentUser!.isStatusActivated) {
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
      
        self.generateAndSaveSessionEntity()
     
        OstAuthorizeSession(userId: self.userId,
                            sessionAddress: self.sessionHelper!.sessionAddress,
                            spendingLimit: self.spendingLimit,
                            expirationHeight: self.sessionHelper!.expirationHeight,
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
        params["address"] = self.sessionHelper!.sessionAddress
        params["expiration_height"] = self.sessionHelper!.expirationHeight
        params["spending_limit"] = self.spendingLimit
        params["nonce"] = 0
        params["status"] = OstSession.Status.CREATED.rawValue
        
        return params
    }
    
    func pollingForAuthorizeSession(_ ostSession: OstSession) {
        
        let successCallback: ((OstSession) -> Void) = { ostSession in
            self.postWorkflowComplete(entity: ostSession)
        }
        
        let failureCallback:  ((OstError) -> Void) = { error in
            self.postError(error)
        }
        Logger.log(message: "test starting polling for userId: \(self.userId) at \(Date.timestamp())")
        
        OstSessionPollingService(userId: ostSession.userId!,
                                 sessionAddress: ostSession.address!,
                                 workflowTransactionCount: workflowTransactionCountForPolling,
                                 successCallback: successCallback, failureCallback: failureCallback).perform()
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
