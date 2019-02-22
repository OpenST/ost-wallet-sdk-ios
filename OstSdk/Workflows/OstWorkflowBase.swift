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
    
    func getUser() throws -> OstUser? {
        return try OstUser.getById(self.userId)
    }
    
    func getCurrentDevice() throws -> OstCurrentDevice? {
        if let ostUser: OstUser = try getUser() {
            return ostUser.getCurrentDevice()
        }
        return nil
    }
    
    func postError(_ error: Error) {
        DispatchQueue.main.async {
            self.delegate.flowInterrupt(error as? OstError ?? OstError.actionFailed("Unexpected error.") )
        }
    }
    
    func postFlowCompleteForGetPaperWallet(entity: Any) {
        Logger.log(message: "OstAddSession flowComplete", parameterToPrint: entity)
        
        DispatchQueue.main.async {
            let contextEntity: OstContextEntity = OstContextEntity(type: .papaerWallet , entity: entity)
            self.delegate.flowComplete(contextEntity);
        }
    }
    
    public func cancelFlow(_ cancelReason: String) {
        
    }
    
    func processOperation() {
        fatalError("processOperation is not override")
    }
    
    //MARK: - authenticate User
    public func authenticateUser() {
        
        let biomatricAuth: BiometricIDAuth = BiometricIDAuth()
        biomatricAuth.authenticateUser { (isSuccess, message) in
            if (isSuccess) {
                self.processOperation()
            }else {
                DispatchQueue.main.async {
                    self.delegate.getPin(self.userId, delegate: self)
                }
            }
        }
    }
    
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
            throw OstError.actionFailed("User is not persent")
        }
        
        if (user.recoveryAddress == nil || user.recoveryAddress!.isEmpty) {
            throw OstError.actionFailed("Recovery address for user is not set.")
        }
        
        if(user.recoveryAddress!.lowercased() == recoveryKey.lowercased()) {
            self.processOperation()
        }else {
            DispatchQueue.main.async {
                self.delegate.invalidPin(self.userId, delegate: self)
            }
        }   
    }
}
