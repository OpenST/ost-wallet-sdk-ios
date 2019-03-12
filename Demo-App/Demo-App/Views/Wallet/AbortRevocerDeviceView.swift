//
//  AbortRevocerDeviceView.swift
//  Demo-App
//
//  Created by aniket ayachit on 11/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk

class AbortRevocerDeviceView: RecoverDeviceView {

    override func recoverDevice() {
        let currentUser = CurrentUser.getInstance()
        //TODO: Future work
//        OstSdk.abortRecoverDevice(
//            userId: currentUser.ostUserId!,
//            uPin: spendingLimitTestField.text!,
//            password: currentUser.userPinSalt!,
//            delegate: self.sdkInteract)
    }
    
    override func viewDidAppearCallback() {
        self.spendingLimitTestField.keyboardType = .numberPad
        spendingLimitTestFieldController?.placeholderText = "pin"
        
        expiresAfterTextField.isHidden = true
        expiresAfterTextField.text = ""
        self.nextButton.setTitle("Abort Recover device", for: .normal);
    }
}
