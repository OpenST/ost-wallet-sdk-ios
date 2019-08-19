/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstBiomatricPerferenceWorkflowController: OstBaseWorkflowController {
    
    
    private let enable: Bool
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: Ost user id
    ///   - enable: Enable biometric
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    @objc
    init(userId: String,
         enable: Bool,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate) {
        
        self.enable = enable
        
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate)
    }
    
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if !self.currentDevice!.isStatusAuthorized {
            throw OstError("ui_i_wc_bpwc_pudv_1", .deviceNotAuthorized)
        }
    }
    
    override func pinProvided(pin: String) {
        self.userPin = pin
        super.pinProvided(pin: pin)
    }
    
    override func onPassphrasePrefixSet(passphrase: String) {
        super.onPassphrasePrefixSet(passphrase: passphrase)
        showLoader(for: .updateBiometricPreference)
    }
    
    override func performUIActions() {
        OstWalletSdk.updateBiometricPreference(userId: self.userId,
                                               enable: self.enable,
                                               delegate: self)
        showLoader(for: .updateBiometricPreference)
    }
    
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .updateBiometricPreference)
    }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        return OstContent.getUpdateBiometricPreferencePinVCConfig()
    }
}
