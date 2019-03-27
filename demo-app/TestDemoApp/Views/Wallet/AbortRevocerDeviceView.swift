//
//  AbortRevocerDeviceView.swift
//  Demo-App
//
//  Created by aniket ayachit on 11/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

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
