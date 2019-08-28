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
        
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate, workflowType: .updateBiometricPreference)
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
        showInitialLoader(for: .updateBiometricPreference)
    }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        return OstContent.getUpdateBiometricPreferencePinVCConfig()
    }
}
