/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

class AbortRevocerDeviceView: RecoverDeviceView {

    override func recoverDevice() {
        let currentUser = CurrentUser.getInstance()
        OstWalletSdk.abortDeviceRecovery(
            userId: currentUser.ostUserId!,
            userPin: spendingLimitTestField.text!,
            passphrasePrefix: currentUser.userPinSalt!,
            delegate: self.sdkInteract)
    }
    
    override func viewDidAppearCallback() {
        self.spendingLimitTestField.keyboardType = .numberPad
        spendingLimitTestFieldController?.placeholderText = "pin"
        
        expiresAfterTextField.isHidden = true
        expiresAfterTextField.text = ""
        self.nextButton.setTitle("Abort Recover device", for: .normal);
    }
}
