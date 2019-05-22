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
    static let PIN_INFO_INVALIDATED = "PIN_INFO_INVALIDATED";
    static let AUTHENTICATED = "AUTHENTICATED";
    
    private var enterPinCount = 0
    
    /// Sets in ordered states for current Workflow
    ///
    /// - Returns: Order states array
    override func getOrderedStates() -> [String] {
        var orderedStates:[String] = super.getOrderedStates()
        
        var inBetweenOrderedStates = [String]()
        inBetweenOrderedStates.append(OstUserAuthenticatorWorkflow.PIN_AUTHENTICATION_REQUIRED)
        inBetweenOrderedStates.append(OstUserAuthenticatorWorkflow.PIN_INFO_RECEIVED)
        inBetweenOrderedStates.append(OstUserAuthenticatorWorkflow.PIN_INFO_INVALIDATED)
        inBetweenOrderedStates.append(OstUserAuthenticatorWorkflow.AUTHENTICATED)
        
        let indexOfDeviceValidated = orderedStates.firstIndex(of: OstWorkflowStateManager.DEVICE_VALIDATED)
        
        orderedStates.insert(contentsOf: inBetweenOrderedStates, at: (indexOfDeviceValidated!+1))
        return orderedStates
    }
    
    /// Should check whether current device authorized or not
    ///
    /// - Returns: `true` if check required, else `false`
    override func shouldCheckCurrentDeviceAuthorization() -> Bool {
        return false
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
            try self.performUserDeviceValidation()
            try onPinInfoReceived()
            
        case OstUserAuthenticatorWorkflow.AUTHENTICATED:
            try self.onUserAuthenticated()
            
        case OstUserAuthenticatorWorkflow.PIN_INFO_INVALIDATED:
            DispatchQueue.main.async {
                self.delegate?.invalidPin(self.userId, delegate: self)
            }
        default:
            try super.process()
            
        }
    }
    
    /// Process action on device validated
    ///
    /// - Throws: OstError
    override func onDeviceValidated() throws {
        
        let isBiometricAuthenticationEnabled = OstWalletSdk.isBiometricEnabled(userId: self.userId)
        let canAuthenticateViaBiometric = shouldAskForBiometricAuthentication()
        if isBiometricAuthenticationEnabled && canAuthenticateViaBiometric {
            
            let BiometricAuth: BiometricIDAuth = BiometricIDAuth()
            BiometricAuth.authenticateUser { (isSuccess, message) in
                if (isSuccess) {
                    self.performState(OstUserAuthenticatorWorkflow.AUTHENTICATED)
                }else {
                    self.performState(OstUserAuthenticatorWorkflow.PIN_AUTHENTICATION_REQUIRED)
                }
            }
        }else {
            self.performState(OstUserAuthenticatorWorkflow.PIN_AUTHENTICATION_REQUIRED)
        }
    }
    
    /// Should ask for biometric authentication
    ///
    /// - Returns: `true` if biometric authentication required, else `false`
    func shouldAskForBiometricAuthentication() -> Bool {
        return true
    }
    
    /// Accept pin from user and validate.
    ///
    /// - Parameters:
    ///   - userPin: User pin.
    ///   - passphrasePrefix: Application server given passphrase prefix.
    func pinEntered(_ userPin: String, passphrasePrefix: String) {
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
        
        let pinManager = OstKeyManagerGateway
            .getOstPinManager(userId: self.userId,
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
            try? self.processState(OstUserAuthenticatorWorkflow.PIN_INFO_INVALIDATED)
        }
    }
    
    //MARK: - Methods to override
    
    /// Proceed with workflow after user is authenticated.
    func onUserAuthenticated() throws {
        fatalError("processOperation is not override")
    }
}
