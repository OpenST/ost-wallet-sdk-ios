/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation


struct OstUserPassphrase {
    var userPin: String
    var passphrasePrefix: String
}

class OstUserAuthenticatorWorkflow: OstWorkflowEngine, OstPinAcceptDelegate {
    
    static let PIN_AUTHENTICATION_REQUIRED = "PIN_AUTHENTICATION_REQUIRED";
    static let PIN_INFO_RECEIVED = "PIN_INFO_RECEIVED";
    static let AUTHENTICATED = "AUTHENTICATED";
    
    private var enterPinCount = 0
    
    /// Get in between ordered states
    ///
    /// - Returns: Order states array
    override func getInBetweenOrderedStates() -> [String] {
        var orderedStates = [String]()
        orderedStates.append(OstUserAuthenticatorWorkflow.PIN_AUTHENTICATION_REQUIRED)
        orderedStates.append(OstUserAuthenticatorWorkflow.PIN_INFO_RECEIVED)
        orderedStates.append(OstUserAuthenticatorWorkflow.AUTHENTICATED)
        
        return orderedStates
    }
    
    /// Perform user device validation
    ///
    /// - Throws: OstError
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        try self.workFlowValidator.isUserActivated()
        try self.workFlowValidator.isDeviceAuthorized()
    }
    
    /// Process
    ///
    /// - Throws: OstError
    override func process() throws {
        switch self.workflowStateManager.getCurrentState() {
        case OstUserAuthenticatorWorkflow.PIN_AUTHENTICATION_REQUIRED:
            DispatchQueue.main.async {
                self.delegate?.getPin(self.userId, delegate: self)
            }
            
        case OstUserAuthenticatorWorkflow.PIN_INFO_RECEIVED:
            try onPinInfoReceived()
            
        case OstUserAuthenticatorWorkflow.AUTHENTICATED:
            self.onUserAuthenticated()
            
        default:
            try super.process()
            
        }
    }
    
    /// Process action on device validated
    ///
    /// - Throws: OstError
    override func onDeviceValidated() throws {
        let biomatricAuth: BiometricIDAuth = BiometricIDAuth()
        biomatricAuth.authenticateUser { (isSuccess, message) in
            if (isSuccess) {
                self.performState(OstUserAuthenticatorWorkflow.AUTHENTICATED)
            }else {
                self.performState(OstUserAuthenticatorWorkflow.PIN_AUTHENTICATION_REQUIRED)
            }
        }
    }
    
    /// Accept pin from user and validate.
    ///
    /// - Parameters:
    ///   - userPin: User pin.
    ///   - passphrasePrefix: Application server given passphrase prefix.
    func pinEntered(_ userPin: String, passphrasePrefix: String) {
        //TODO: fix this.
        // Confirm whether user is actived. check whether
        do {
            try self.performUserDeviceValidation()
        }catch let error{
            self.postError(error)
            return
        }
        
        let userPassphrase = OstUserPassphrase(userPin: userPin, passphrasePrefix: passphrasePrefix)
        
        self.performState(OstUserAuthenticatorWorkflow.PIN_INFO_RECEIVED, withObject: userPassphrase)
    }
    
    /// Perform action on pin info received
    ///
    /// - Throws: OstError
    func onPinInfoReceived() throws {
        guard let userPassphrase =
            self.workflowStateManager.getStateObject() as? OstUserPassphrase else {
                throw OstError("w_uaw_opir_1", OstErrorText.unknown)
        }
        
        self.enterPinCount += 1
        
        let pinManager = OstPinManager(userId: self.userId,
                                       passphrasePrefix: userPassphrase.passphrasePrefix,
                                       userPin: userPassphrase.userPin)
        do {
            try pinManager.validatePin()
            DispatchQueue.main.async {
                self.delegate?.pinValidated(self.userId)
            }
            try self.processState(OstUserAuthenticatorWorkflow.AUTHENTICATED)
        } catch {
            self.userAuthenticationFailed()
        }
    }
    
    /// Check retry count of pin validation.
    func userAuthenticationFailed() {
        if (OstConfig.getPinMaxRetryCount() <= self.enterPinCount) {
            self.postError(OstError("w_wb_uaf_1", .maxUserValidatedCountReached))
        }else{
            try? self.processState(OstUserAuthenticatorWorkflow.PIN_AUTHENTICATION_REQUIRED)
        }
    }
    
    //MARK: - Methods to override
    
    /// Proceed with workflow after user is authenticated.
    func onUserAuthenticated() {
        fatalError("processOperation is not override")
    }
}
