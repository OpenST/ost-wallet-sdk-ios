/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstWorkflowBase: OstPinAcceptDelegate {
    
    var userId: String
    var delegate: OstWorkflowDelegate
    var currentUser: OstUser? {
        do {
            return try OstUser.getById(self.userId)
        }catch {
            return nil
        }
    }
    var currentDevice: OstCurrentDevice? {
        return self.currentUser?.getCurrentDevice()
    }
    var workFlowValidator: OstWorkflowValidator? = nil
    
    private var enterPinCount = 0
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - delegate: Callback.
    init(userId: String,
         delegate: OstWorkflowDelegate) {
        
        self.userId = userId
        self.delegate = delegate
    }

    /// Perform
    func perform() {
        let asyncQueue: DispatchQueue = DispatchQueue(label: "asyncThread")
        asyncQueue.async {
            let queue: DispatchQueue = self.getWorkflowQueue()
            queue.sync {
                do {
                    try self.beforeProcess()
                    self.workFlowValidator = try OstWorkflowValidator(withUserId: self.userId)
                    
                    try self.validateParams()
                    try self.process()
                }catch let error {
                    self.postError(error)
                }
            }
        }
    }
    
    /// Perform any tasks that are prerequisite for the workflow,
    /// this is called before validateParams() and process()
    ///
    /// - Throws: OstError
    func beforeProcess() throws {
        let group = DispatchGroup()
        group.enter()
        OstSdkSync(
            userId: self.userId,
            forceSync: false,
            syncEntites: .User, .Token, .CurrentDevice, onCompletion: { (isFetched) in
                group.leave()
        }
            ).perform()
        
        group.wait()
    }
    
    /// Validiate basic parameters for workflow
    ///
    /// - Throws: OstError
    func validateParams() throws {
        if(nil == self.currentUser) {
            throw OstError("w_wb_vp_1", .userNotFound)
        }
        if(nil == self.currentDevice) {
            throw OstError("w_wb_vp_2", .deviceNotFound)
        }
        try self.workFlowValidator!.isAPIKeyAvailable()
        try self.workFlowValidator!.isTokenAvailable()
    }
    
    /// Send callback to application if error occured in workflow.
    ///
    /// - Parameter error: OstError
    func postError(_ error: Error) {
        let workflowContext: OstWorkflowContext = getWorkflowContext()
        DispatchQueue.main.async {
            if ( error is OstError ) {
                self.delegate.flowInterrupted(workflowContext: workflowContext, error: error as! OstError);
            }
            else {
                //Unknown Error. Post Something went wrong.
                let ostError:OstError = OstError("w_wb_pe_1", OstErrorText.sdkError)
                self.delegate.flowInterrupted(workflowContext: workflowContext, error: ostError )
            }
        }
    }
    
    /// Send callback to application about request has been sent to server.
    ///
    /// - Parameter entity: OstEntity whose response has received.
    func postRequestAcknowledged(entity: Any) {
        let workflowContext: OstWorkflowContext = getWorkflowContext()
        let contextEntity: OstContextEntity = getContextEntity(for: entity)
        DispatchQueue.main.async {
            self.delegate.requestAcknowledged(workflowContext: workflowContext, ostContextEntity: contextEntity)
        }
    }
    
    /// Send workflow complete callback to user.
    ///
    /// - Parameter entity: OstEntity
    func postWorkflowComplete(entity: Any) {
        let workflowContext: OstWorkflowContext = getWorkflowContext()
        let contextEntity: OstContextEntity = getContextEntity(for: entity)
        
        DispatchQueue.main.async {
            self.delegate.flowComplete(workflowContext: workflowContext, ostContextEntity: contextEntity)
        }
    }
    
    /// Cancel currently ongoing workflow.
    ///
    /// - Parameter cancelReason: reason to cancel.
    public func cancelFlow() {
        let ostError:OstError = OstError("w_wb_cf_1", OstErrorText.userCanceled)
        self.postError(ostError)
    }
    
    //MARK: - Authenticate User
    /// authenticate user with biomatrics or user pin if biomatrics failed.
    func authenticateUser() {
        let biomatricAuth: BiometricIDAuth = BiometricIDAuth()
        biomatricAuth.authenticateUser { (isSuccess, message) in
            if (isSuccess) {
                self.proceedWorkflowAfterAuthenticateUser()
            }else {
                DispatchQueue.main.async {
                    self.delegate.getPin(self.userId, delegate: self)
                }
            }
        }
    }
    
    /// Get OstWorkflowValidator object.
    ///
    /// - Returns: OstWorkflowValidator
    /// - Throws: OstError
    func getWorkflowValidator() throws -> OstWorkflowValidator {
        if (self.workFlowValidator == nil) {
            self.workFlowValidator = try OstWorkflowValidator(withUserId: self.userId)
        }
        return self.workFlowValidator!
    }
    
    /// Accept pin from user and validate.
    ///
    /// - Parameters:
    ///   - userPin: User pin.
    ///   - passphrasePrefix: Application server given passphrase prefix.
    func pinEntered(_ userPin: String, passphrasePrefix: String) {
        self.enterPinCount += 1
        let queue: DispatchQueue = getWorkflowQueue()
        queue.async {
            let pinManager = OstPinManager(userId: self.userId,
                                           passphrasePrefix: passphrasePrefix,
                                           userPin: userPin)
            do {
                try pinManager.validatePin()
                DispatchQueue.main.async {
                    self.delegate.pinValidated(self.userId)
                }
                self.proceedWorkflowAfterAuthenticateUser()
            } catch {
                self.userAuthenticationFailed()
            }
        }
    }
    
    /// Check retry count of pin validation.
    func userAuthenticationFailed() {
        if (OstConfig.getPinMaxRetryCount() <= self.enterPinCount) {
            self.postError(OstError("w_wb_uaf_1", .maxUserValidatedCountReached))
        }else{
            DispatchQueue.main.async {
                self.delegate.invalidPin(self.userId, delegate: self)
            }
        }
    }
    
    //MARK: - Methods to override
    
    /// Get worflow running queue.
    ///
    /// - Returns: DispatchQueue
    func getWorkflowQueue() -> DispatchQueue {
        fatalError("getWorkflowQueue not override.")
    }
    
    /// Process with workflow.
    func process() throws {
        fatalError("process not override.")
    }
    
    /// Proceed with workflow after user is authenticated.
    func proceedWorkflowAfterAuthenticateUser() {
        fatalError("processOperation is not override")
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    func getWorkflowContext() -> OstWorkflowContext {
        fatalError("getWorkflowContext not override.")
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    func getContextEntity(for entity: Any) -> OstContextEntity {
        fatalError("getContextEntity not override.")
    }
    
    
}
