//
//  RecoverDevice.swift
//  Demo-App
//
//  Created by aniket ayachit on 08/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk

class RecoverDeviceView: AddSessionView {
    @objc override func didTapNext(sender: Any) {
        //        super.didTapNext(sender: sender)
        let currentUser = CurrentUser.getInstance()
        
        OstSdk.recoverDeviceInitialize(
            userId: currentUser.ostUserId!,
            recoverDeviceAddress: spendingLimitTestField.text!,
            uPin: expiresAfterTextField.text!,
            password: currentUser.userPinSalt!,
            delegate: self.sdkInteract)
        
        self.nextButton.isHidden = true
        self.cancelButton.isHidden = true
        self.activityIndicator.startAnimating()
    }
    
    override func viewDidAppearCallback() {
        spendingLimitTestFieldController?.placeholderText = "Device address to recover"
        expirationHeightTextFieldController?.placeholderText = "Pin"
        expiresAfterTextField.delegate = self
        expiresAfterTextField.text = ""
        self.nextButton.setTitle("Recover device", for: .normal);
    }
    
    override func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true;
    }
}
