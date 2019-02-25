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
    
    var uPin: String = ""
    var appUserPassword : String = ""
    var saltResponse: [String: Any]? = nil
    
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
//        DispatchQueue.main.async {
//            self.delegate.flowInterrupted(error as? OstError ?? OstError.actionFailed("Unexpected error.") )
//        }
        
        let workflowContext: OstWorkflowContext = getWorkflowContext()
        let ostError: OstError = error as? OstError ?? OstError("w_wb_pe_1", .unexpectedError)
        DispatchQueue.main.async {
            self.delegate.flowInterrupted1(workflowContext: workflowContext, error: ostError)
        }
    }
    
    func postWorkflowComplete(entity: Any) {
        let workflowContext: OstWorkflowContext = getWorkflowContext()
        let contextEntity: OstContextEntity = getContextEntity(for: entity)
        
        DispatchQueue.main.async {
            self.delegate.flowComplete1(workflowContext: workflowContext, ostContextEntity: contextEntity)
        }
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
    
    public func cancelFlow(_ cancelReason: String) {
        
    }
    
    func proceedWorkflowAfterAuthenticateUser() {
        fatalError("processOperation is not override")
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
    
    /// Accept pin from user and valdiate.
    ///
    /// - Parameters:
    ///   - uPin: user pin.
    ///   - appUserPassword: application server given password.
    func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        workflowThread.async {
            do {
                self.uPin = uPin
                self.appUserPassword = appUserPassword
                
                if (self.saltResponse != nil) {
                    try self.validatePin()
                }else {
                    try OstAPISalt(userId: self.userId).getRecoverykeySalt(onSuccess: { (saltResponse) in
                        do {
                            self.saltResponse = saltResponse
                            try self.validatePin()
                        }catch let error {
                            self.postError(error)
                        }
                        
                    }, onFailure: { (error) in
                        self.postError(error)
                    })
                }
                
            }catch let error {
                self.postError(error)
            }
        }
    }
    func validatePin() throws {
        let salt = self.saltResponse!["scrypt_salt"] as! String
        let recoveryKey = try OstCryptoImpls().generateRecoveryKey(password: self.appUserPassword,
                                                                   pin: self.uPin,
                                                                   userId: self.userId,
                                                                   salt: salt,
                                                                   n: OstConstants.OST_RECOVERY_PIN_SCRYPT_N,
                                                                   r: OstConstants.OST_RECOVERY_PIN_SCRYPT_R,
                                                                   p: OstConstants.OST_RECOVERY_PIN_SCRYPT_P,
                                                                   size: OstConstants.OST_RECOVERY_PIN_SCRYPT_DESIRED_SIZE_BYTES)
        
        guard let user: OstUser = try getUser() else {
            throw OstError("w_wb_vp_1",.userNotFound)
        }
        
        if (user.recoveryAddress == nil || user.recoveryAddress!.isEmpty) {
            throw OstError("w_wb_vp_2", .recoveryAddressNotFound);            
        }
        
        if(user.recoveryAddress!.lowercased() == recoveryKey.lowercased()) {
            DispatchQueue.main.async {
                self.delegate.pinValidated(self.userId)
            }
            self.proceedWorkflowAfterAuthenticateUser()
        }else {
            DispatchQueue.main.async {
                self.delegate.invalidPin(self.userId, delegate: self)
            }
        }
    }
}
