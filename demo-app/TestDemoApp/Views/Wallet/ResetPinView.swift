//
//  ResetPinView.swift
//  Demo-App
//
//  Created by aniket ayachit on 07/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

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
