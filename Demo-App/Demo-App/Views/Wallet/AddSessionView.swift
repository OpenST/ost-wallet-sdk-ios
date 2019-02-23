//
//  AddSessionView.swift
//  Demo-App
//
//  Created by aniket ayachit on 23/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk
import MaterialComponents

class AddSessionView: BaseWalletWorkflowView {

    @objc override func didTapNext(sender: Any) {
        let currentUser = CurrentUser.getInstance();
        //TODO: add session
        if (validateSpendingLimit() && validateExpirationHeight()) {
            super.didTapNext(sender: sender);
            OstSdk.addSession(userId:  currentUser.ostUserId!,
                              spendingLimit: self.spendingLimitTestField.text!,
                              expirationHeight: Int(self.expirationHeightTextField.text!)!,
                              delegate: self.sdkInteract)
        }
    }
    
    // Mark - Sub Views
    let logoImageView: UIImageView = {
        let baseImage = UIImage.init(named: "Logo")
        let logoImageView = UIImageView(image: baseImage);
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()

    //Add text fields
    let spendingLimitTestField: MDCTextField = {
        let spendingLimitTestFiled = MDCTextField()
        spendingLimitTestFiled.translatesAutoresizingMaskIntoConstraints = false
        spendingLimitTestFiled.clearButtonMode = .unlessEditing
        spendingLimitTestFiled.placeholderLabel.text = ""
        return spendingLimitTestFiled
    }()
    var spendingLimitTestFieldController: MDCTextInputControllerOutlined? = nil
    
    let expirationHeightTextField: MDCTextField = {
        let expirationHeightTextField = MDCTextField()
        expirationHeightTextField.translatesAutoresizingMaskIntoConstraints = false
        expirationHeightTextField.clearButtonMode = .unlessEditing
        return expirationHeightTextField
    }()
    var expirationHeightTextFieldController: MDCTextInputControllerOutlined? = nil
    
    override func addSubViews() {
        let scrollView = self;
        
        self.spendingLimitTestFieldController = MDCTextInputControllerOutlined(textInput: spendingLimitTestField)
        self.expirationHeightTextFieldController = MDCTextInputControllerOutlined(textInput: expirationHeightTextField)
        
        self.spendingLimitTestFieldController!.placeholderText = "Spending Limit"
//        self.spendingLimitTestField.delegate = walletViewController! as? UITextFieldDelegate
        self.spendingLimitTestField.keyboardType = .phonePad
        
        self.expirationHeightTextFieldController!.placeholderText = "Expiration Height"
//        self.expirationHeightTextField.delegate = walletViewController! as? UITextFieldDelegate
        self.expirationHeightTextField.keyboardType = .phonePad
        
        registerKeyboardNotifications()
        
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(spendingLimitTestField)
        scrollView.addSubview(expirationHeightTextField)
        
        super.addSubViews();
        self.nextButton.setTitle("Create Session", for: .normal);
    }
    
    override func addSubviewConstraints() {
        let scrollView = self;
        
        // Constraints
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: logoImageView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: scrollView.contentLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 100))
        constraints.append(NSLayoutConstraint(item: logoImageView,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        constraints.append(NSLayoutConstraint(item: spendingLimitTestField,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: logoImageView,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 22))
        constraints.append(NSLayoutConstraint(item: spendingLimitTestField,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        constraints.append(contentsOf:
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[spendingLimit]-|",
                                           options: [],
                                           metrics: nil,
                                           views: [ "spendingLimit" : spendingLimitTestField]))
        constraints.append(NSLayoutConstraint(item: expirationHeightTextField,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: spendingLimitTestField,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 8))
        constraints.append(NSLayoutConstraint(item: expirationHeightTextField,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        constraints.append(contentsOf:
            NSLayoutConstraint.constraints(withVisualFormat: "H:|-[expirationHeight]-|",
                                           options: [],
                                           metrics: nil,
                                           views: [ "expirationHeight" : expirationHeightTextField]))
        
        NSLayoutConstraint.activate(constraints)
        super.addBottomSubviewConstraints(afterView:expirationHeightTextField);
    }
    
    //MARK - Keyboard Notfications
    @objc override func keyboardWillShow(notification: NSNotification) {
        let keyboardFrame =
            (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0);
    }
    
    @objc override func keyboardWillHide(notification: NSNotification) {
        self.contentInset = UIEdgeInsets.zero;
    }
    
    func validateSpendingLimit() -> Bool {
        if (spendingLimitTestField.text!.count < 4) {
            spendingLimitTestFieldController!.setErrorText("Spending limit should be greater than 999",
                                                     errorAccessibilityValue: nil);
            return false;
        }
        spendingLimitTestFieldController!.setErrorText(nil,errorAccessibilityValue: nil);
        return true;
    }
    
    func validateExpirationHeight() -> Bool {
        if (expirationHeightTextField.text!.count < 4) {
            expirationHeightTextFieldController!.setErrorText("expiration height should be greater than 999",
                                                         errorAccessibilityValue: nil);
            return false;
        }
        expirationHeightTextFieldController!.setErrorText(nil,errorAccessibilityValue: nil);
        return true;
    }
}
