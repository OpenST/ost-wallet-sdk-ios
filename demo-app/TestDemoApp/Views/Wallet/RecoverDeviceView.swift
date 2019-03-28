/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class RecoverDeviceView: AddSessionView {
    @objc override func didTapNext(sender: Any) {
        recoverDevice()
        self.nextButton.isHidden = true
        self.cancelButton.isHidden = true
        self.activityIndicator.startAnimating()
    }
    
    func recoverDevice() {
        let currentUser = CurrentUser.getInstance()
        OstWalletSdk.initiateDeviceRecovery(
            userId: currentUser.ostUserId!,
            recoverDeviceAddress: spendingLimitTestField.text!,
            userPin: expiresAfterTextField.text!,
            passphrasePrefix: currentUser.userPinSalt!,
            delegate: self.sdkInteract)
    }
    
    override func viewDidAppearCallback() {
        spendingLimitTestFieldController?.placeholderText = "Device address to recover"
        expirationHeightTextFieldController?.placeholderText = "Pin"
         self.spendingLimitTestField.keyboardType = .default
        expiresAfterTextField.delegate = self
        expiresAfterTextField.text = ""
        self.nextButton.setTitle("Recover device", for: .normal);
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
}
