//
//  OstBase.swift
//  OstSdk
//
//  Created by aniket ayachit on 09/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstWorkflowBase: OstPinAcceptProtocol {
    var userId: String
    var delegate: OstWorkFlowCallbackProtocol
    var workflowThread: DispatchQueue
    
    var retryCount = 0
    let maxRetryCount = 3
    
    var currentUser: OstUser? = nil
    var currentDevice: OstCurrentDevice? = nil
    
    var workFlowValidator: OstWorkflowValidator? = nil
    
    init(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        self.userId = userId
        self.delegate = delegate
        self.workflowThread = DispatchQueue.global()
    }
    
    func perform() {
        fatalError("************* perform didnot override ******************")
    }
    
    /// Get user for given userid
    ///
    /// - Returns: OstUser entity
    /// - Throws: OstError
    func getUser() throws -> OstUser? {
        return try OstUser.getById(self.userId)
    }
    
    /// get current device for user
    ///
    /// - Returns: OstCurrentDevice object
    /// - Throws: OstError
    func getCurrentDevice() throws -> OstCurrentDevice? {
        if let ostUser: OstUser = try getUser() {
            return ostUser.getCurrentDevice()
        }
        return nil
    }
    
    func postError(_ error: Error) {
        let workflowContext: OstWorkflowContext = getWorkflowContext()
        DispatchQueue.main.async {
            if ( error is OstError ) {
                self.delegate.flowInterrupted1(workflowContext: workflowContext, error: error as! OstError);
            }
            else {
                //Unknown Error. Post Something went wrong.
                let ostError:OstError = OstError("w_wb_pe_1", OstErrorText.sdkError)
                self.delegate.flowInterrupted1(workflowContext: workflowContext, error: ostError )
            }
        }
    }

    /// Post request acknowledged.
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
            self.delegate.flowComplete1(workflowContext: workflowContext, ostContextEntity: contextEntity)
        }
    }
    
    /// Cancel currently ongoing workflow.
    ///
    /// - Parameter cancelReason: reason to cancel.
    public func cancelFlow(_ cancelReason: String) {
        
    }
    
    //MARK: - Authenticate User
    /// authenticate user with biomatrics or user pin if biomatrics failed.
    public func authenticateUser() {
        
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
    
    func getWorkflowValidator() throws -> OstWorkflowValidator {
        if (self.workFlowValidator == nil) {
            self.workFlowValidator = try OstWorkflowValidator(withUserId: self.userId)
        }
        return self.workFlowValidator!
    }

    /// Accept pin from user and validate.
    ///
    /// - Parameters:
    ///   - uPin: user pin.
    ///   - appUserPassword: application server given password.
    func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        self.retryCount += 1
        workflowThread.async {
            
            let pinManager = OstPinManager(userId: self.userId, password: appUserPassword, pin: uPin)
            
            do {
                let isPinValid  = try pinManager.validatePin()
                if isPinValid == false {
                    self.userAuthenticationFailed()
                    return
                }
                DispatchQueue.main.async {
                    self.delegate.pinValidated(self.userId)
                }
                self.proceedWorkflowAfterAuthenticateUser()
            } catch let error{
                self.postError(error)
            }
        }
    }
    
    func userAuthenticationFailed() {
        if (self.maxRetryCount <= self.retryCount) {
            self.postError(OstError("w_wb_pe_1", .maxUserValidatedCountReached))
        }else{
            DispatchQueue.main.async {
                self.delegate.invalidPin(self.userId, delegate: self)
            }
        }
    }
    
    //MARK: - Methods to override
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
