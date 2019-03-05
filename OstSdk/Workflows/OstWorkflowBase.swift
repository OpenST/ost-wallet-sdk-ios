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
    
    var uPin: String = ""
    var appUserPassword : String = ""
    var saltResponse: [String: Any]? = nil
    
    var retryCount = 0
    let maxRetryCount = 3
    
    var currentUser: OstUser? = nil
    var currentDevice: OstCurrentDevice? = nil
    
    var workFlowValidator: OstWorkflowValidator? = nil
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - delegate: Callback.
    init(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        self.userId = userId
        self.delegate = delegate
    }
    
    /// Perform
    func perform() {
        let thread: DispatchQueue = getWorkflowThread()
        thread.async {
            do {
                try self.setUser()
                try self.setCurrentDevice()
                
                try self.validateParams()
                
                try self.process()
            }catch let error {
                self.postError(error)
            }
        }
    }

    /// Set user entity.
    ///
    /// - Throws: OstError
    func setUser() throws {
        self.currentUser = try OstUser.getById(self.userId)
    }

    /// Set Current Device entity
    ///
    /// - Throws: OstError
    func setCurrentDevice() throws {
        self.currentDevice = self.currentUser?.getCurrentDevice()
    }

    /// Valdiate basic parameters for workflow
    ///
    /// - Throws: OstError
    func validateParams() throws {
        let validator = try OstWorkflowValidator(withUserId: self.userId)
        
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
    
    /// Send callback to application if error occured in workflow.
    ///
    /// - Parameter error: OstError
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
    ///   - uPin: user pin.
    ///   - appUserPassword: application server given password.
    func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        self.retryCount += 1
        let thread: DispatchQueue = getWorkflowThread()
        thread.async {
            self.uPin = uPin
            self.appUserPassword = appUserPassword
            do {
                let isPinValid  = try self.validatePin()
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

    /// Get salt.
    ///
    /// - Returns: Salt for user id
    /// - Throws: OstError
    func getSalt() throws -> String {
        if (self.saltResponse == nil) {
            self.saltResponse = try self.fetchSalt()
        }
        return self.saltResponse!["scrypt_salt"] as! String
    }
    
    /// Fetch salt from server if salt is not present locally.
    ///
    /// - Returns: Server salt entity
    /// - Throws: OstError
    private func fetchSalt() throws -> [String: Any]? {
        let group = DispatchGroup()
        
        var salt: [String: Any]?
        var err: OstError? = nil
        do {
            group.enter()
            try OstAPISalt(userId: self.userId)
                .getRecoverykeySalt(
                    onSuccess: { (saltResponse) in
                        salt = saltResponse
                        group.leave()
                    },
                    onFailure: { (error) in
                        err = error
                        group.leave()
                    }
                )
            group.wait()
        }catch let error{
            err = error as? OstError
            group.leave()
        }
        if (err != nil) {
            throw err!
        }
        return salt
    }
    
    /// Validate pin provided by user.
    ///
    /// - Returns: true if pin is validated.
    /// - Throws: OstError
    func validatePin() throws -> Bool{
        let validator = try self.getWorkflowValidator()
        let salt = try self.getSalt()
        
        try validator.validatePinLength(self.uPin)
        do {
            let isPinValid = try validator.validatePin(
                pin: self.uPin,
                appPassword: self.appUserPassword,
                salt: salt
            )
            if (isPinValid) {
                return isPinValid
            }
            throw OstError("", "")
        } catch {
            // Fallback
            let recoveryOwnerAddress = try OstKeyManager(userId: self.userId)
                .getRecoveryOwnerAddressFrom(
                    password: self.appUserPassword,
                    pin: self.uPin,
                    salt: salt
                )
            let user = try OstUser.getById(self.userId)
            return recoveryOwnerAddress.caseInsensitiveCompare((user!.recoveryOwnerAddress)!) ==  .orderedSame
        }
    }
    
    /// Check retry count of pin validation.
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
    
    /// Get worflow running thread.
    ///
    /// - Returns: Thread
    func getWorkflowThread() -> DispatchQueue {
        fatalError("getWorkflowThread not override.")
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
