/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstAddSessionWorkflowController: OstBaseWorkflowController {
    
    private let spendingLimit: String
    private let expireAfter: TimeInterval
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: Ost user id
    ///   - expireAfter: Relative time
    ///   - spendingLimit: Spending limit for transaction
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    @objc 
    init(userId: String,
         expireAfter: TimeInterval,
         spendingLimit: String,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate) {
        
        self.spendingLimit = spendingLimit
        self.expireAfter = expireAfter
        
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate)
    }
    
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if !self.currentDevice!.isStatusAuthorized {
            throw OstError("ui_i_wc_aswc_pudv_2", OstErrorCodes.OstErrorCode.deviceNotAuthorized)
        }
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .addSession)
    }
    
    override func performUIActions() {
        OstWalletSdk.addSession(userId: self.userId,
                                spendingLimit: self.spendingLimit,
                                expireAfterInSec: self.expireAfter,
                                delegate: self)
        showLoader(for: .addSession)
    }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        return OstContent.getAddSessinoPinVCConfig()
    }
    
    override func onPassphrasePrefixSet(passphrase: String) {
        super.onPassphrasePrefixSet(passphrase: passphrase)
        showLoader(for: .addSession)
    }
    
    /// Mark - OstPinAcceptDelegate
    override func pinProvided(pin: String) {
        self.userPin = pin
        super.pinProvided(pin: pin)
    }
}
