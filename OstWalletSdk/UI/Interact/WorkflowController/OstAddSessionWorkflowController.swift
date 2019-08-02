/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAddSessionWorkflowController: OstBaseWorkflowController {
    
    private let spendingLimit: String
    private let expireAfter: TimeInterval
    private var pinAcceptDelegate: OstPinAcceptDelegate? = nil
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: Ost user id
    ///   - expireAfter: Relative time
    ///   - spendingLimit: Spending limit for transaction
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    init(userId: String,
         expireAfter: TimeInterval,
         spendingLimit: String,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate) {
        
        self.spendingLimit = spendingLimit
        self.expireAfter = expireAfter
        
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate)
    }
    
    override func performUserDeviceValidation() throws {
        if !self.currentUser!.isStatusActivated {
            throw OstError("i_wc_adswc_pudv_1", .userNotActivated);
        }
        
        if !self.currentDevice!.isStatusAuthorized {
            throw OstError("i_wc_adswc_pudv_2", OstErrorCodes.OstErrorCode.deviceNotAuthorized)
        }
    }
    
    @objc override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .addSession)
    }
    
    override func performUIActions() {
        OstWalletSdk.addSession(userId: self.userId,
                                spendingLimit: self.spendingLimit,
                                expireAfterInSec: self.expireAfter,
                                delegate: self)
        
        self.progressIndicator = OstProgressIndicator(textCode: .creatingSession)
        self.progressIndicator?.show()
        
    }
    
    override func getPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        self.progressIndicator?.hide()
        self.progressIndicator = nil
        
        self.pinAcceptDelegate = delegate
        
        if nil == getPinViewController {
            self.getPinViewController = OstPinViewController
                .newInstance(pinInputDelegate: self,
                             pinVCConfig: OstPinVCConfig.getAddSessinoPinVCConfig())
        }
        
        self.getPinViewController?.presentVCWithNavigation()
    }
    
    /// Mark - OstPassphrasePrefixAcceptDelegate
    fileprivate var userPassphrasePrefix:String?
    override func setPassphrase(ostUserId: String, passphrase: String) {
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            self.flowInterrupted(workflowContext: OstWorkflowContext(workflowType: .addSession),
                                 error: OstError("wui_i_wfc_auwc_gp_1", .pinValidationFailed)
            );
            return;
        }
        
        
        self.pinAcceptDelegate?.pinEntered(self.userPin!,
                                           passphrasePrefix: passphrase)
        
        self.userPin = nil;
        showLoader(progressText: .creatingSession)
    }
    
}
