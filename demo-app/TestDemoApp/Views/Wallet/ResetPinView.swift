/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit
import OstWalletSdk

class ResetPinView: AddSessionView {
    
    @objc override func didTapNext(sender: Any) {
//        super.didTapNext(sender: sender)
        let currentUser = CurrentUser.getInstance()
        
        OstWalletSdk.resetPin(userId: currentUser.ostUserId!,
                        passphrasePrefix: currentUser.userPinSalt!,
                        oldUserPin: spendingLimitTestField.text!,
                        newUserPin: expiresAfterTextField.text!,
                        delegate: self.sdkInteract)
        
        self.nextButton.isHidden = true
        self.cancelButton.isHidden = true
        self.activityIndicator.startAnimating()
    }
    
    override func viewDidAppearCallback() {
        spendingLimitTestFieldController?.placeholderText = "Old Pin"
        expirationHeightTextFieldController?.placeholderText = "New Pin"
        expiresAfterTextField.delegate = self
        expiresAfterTextField.text = ""
        self.nextButton.setTitle("Reset Pin", for: .normal);
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
}
