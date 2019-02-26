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
        
        let workflowContext: OstWorkflowContext = getWorkflowContext()
        DispatchQueue.main.async {
            if ( error is OstError1 ) {
                self.delegate.flowInterrupted1(workflowContext: workflowContext, error: error as! OstError1)
            }
            else {
                //Unknown Error. Post Something went wrong.
                let ostError:OstError1 = OstError1("wb_pe_1", OstErrorText.sdkError)
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
    
    /// Accept pin from user and valdiate.
    ///
    /// - Parameters:
    ///   - uPin: user pin.
    ///   - appUserPassword: application server given password.
    func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        workflowThread.async {
            self.uPin = uPin
            self.appUserPassword = appUserPassword
            
            let recoveryPinString: String = OstCryptoImpls().getRecoveryPinString(password: self.appUserPassword,
                                                                                  pin: self.uPin,
                                                                                  userId: self.userId)
            if OstKeyManager(userId: self.userId).verifyRecoveryPinString(recoveryPinString) {
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
