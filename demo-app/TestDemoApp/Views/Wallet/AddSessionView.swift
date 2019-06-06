/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk
import MaterialComponents

class AddSessionView: BaseWalletWorkflowView, UITextFieldDelegate {

    @objc override func didTapNext(sender: Any) {
        let currentUser = CurrentUser.getInstance();
            super.didTapNext(sender: sender);
            let expireAfter = (self.expiresAfterSelectedIndex + 1) * 24 * 60 * 60;
            OstWalletSdk.addSession(userId: currentUser.ostUserId!,
                                    spendingLimit: self.spendingLimitTestField.text ?? "",
                                    expireAfterInSec: Double(expireAfter),
                                    delegate: self.workflowCallback)
    }
  
    // Mark - Expires After Data
    static let DEFAULT_EXPIRES = 13;
    let expiresOptions:[String] = {
        var expiresOptions:[String] = [];
        for cnt in 1...30 {
            switch(cnt) {
            case 1:
                expiresOptions.append("1 Day");
                break;
            case 7:
                expiresOptions.append("1 Week");
                break;
            case 14:
                expiresOptions.append("2 Weeks");
                break;
            case 21:
                expiresOptions.append("3 Weeks");
                break;
            case 28:
                expiresOptions.append("4 Weeks");
                break;
            default:
                expiresOptions.append("\(cnt) Days");
            }
            
            
            
        }
        return expiresOptions;
    }();
    
    // Mark - Sub Views
    let logoImageView: UIImageView = {
        let baseImage = UIImage.init(named: "Logo")
        let logoImageView = UIImageView(image: baseImage);
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()

    //Add text fields
    var spendingLimitTestField: MDCTextField = {
        let spendingLimitTestFiled = MDCTextField()
        spendingLimitTestFiled.translatesAutoresizingMaskIntoConstraints = false
        spendingLimitTestFiled.clearButtonMode = .never
        spendingLimitTestFiled.placeholderLabel.text = ""
        return spendingLimitTestFiled
    }()
    var spendingLimitTestFieldController: MDCTextInputControllerOutlined? = nil
  
    var expiresAfterSelectedIndex:Int = DEFAULT_EXPIRES;
    var expiresAfterTextField: MDCTextField = {
        let expiresAfterTextField = MDCTextField()
        expiresAfterTextField.translatesAutoresizingMaskIntoConstraints = false
        expiresAfterTextField.clearButtonMode = .never
        return expiresAfterTextField
    }()
    var expirationHeightTextFieldController: MDCTextInputControllerOutlined? = nil
    
    override func addSubViews() {
        let scrollView = self;
        
        self.spendingLimitTestFieldController = MDCTextInputControllerOutlined(textInput: spendingLimitTestField)
        self.expirationHeightTextFieldController = MDCTextInputControllerOutlined(textInput: expiresAfterTextField)

        self.spendingLimitTestFieldController!.placeholderText = "Spending Limit"
        self.spendingLimitTestField.keyboardType = .numberPad
      
        self.expirationHeightTextFieldController!.placeholderText = "Expiration Height"
        self.expiresAfterTextField.keyboardType = .numberPad
        
        registerKeyboardNotifications()
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(spendingLimitTestField)
        scrollView.addSubview(expiresAfterTextField)
        
        super.addSubViews();
        self.nextButton.setTitle("Create Session", for: .normal);
      
        self.expiresAfterTextField.delegate = self;
        self.expiresAfterTextField.text = expiresOptions[AddSessionView.DEFAULT_EXPIRES];
      
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
        constraints.append(NSLayoutConstraint(item: expiresAfterTextField,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: spendingLimitTestField,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 8))
        constraints.append(NSLayoutConstraint(item: expiresAfterTextField,
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
                                           views: [ "expirationHeight" : expiresAfterTextField]))
        
        NSLayoutConstraint.activate(constraints)
        super.addBottomSubviewConstraints(afterView:expiresAfterTextField);
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
    
    var isShowingActionSheet = false;
    func showExpiresAfterActionSheet() {
        if ( isShowingActionSheet ) {
            //return;
        }
        isShowingActionSheet = true;
        let actionSheet = UIAlertController(title: "Session Validity", message: "How long should your sesstion be valid for?", preferredStyle: UIAlertController.Style.actionSheet);
        for cnt in 0..<expiresOptions.count {
            let currAction = getActionForIndex(indx: cnt);
            actionSheet.addAction(currAction);
        }
        self.walletViewController?.present(actionSheet, animated: true, completion: {
            self.isShowingActionSheet = false;
        });
    }
    
    func getActionForIndex(indx:Int) -> UIAlertAction {
        let displayText = expiresOptions[indx];
        return UIAlertAction(title: displayText, style: .default, handler: { (UIAlertAction) in
            self.expiresAfterSelectedIndex = indx;
            self.expiresAfterTextField.text = displayText;
        })
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        showExpiresAfterActionSheet();
        return false;
    }

}
