/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import MaterialComponents
import OstWalletSdk

class UserDetailsView: BaseWalletWorkflowView {


    //Add text fields
//    let userNameTF: MDCTextField = {
//        let textField = MDCTextField();
//        textField.translatesAutoresizingMaskIntoConstraints = false;
//        textField.placeholderLabel.text = "User Name";
//        return textField;
//    }()

    let userIdTF: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Ost-User-Id";
        return textField;
    }()
    
    let tokenIdTF: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Token Id";
        return textField;
    }()
    
    let tokenHolderTF: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Token Holder Address";
        return textField;
    }()
    
    let recoveryAddressTF: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Recovery Key Address";
        return textField;
    }()
    
    let recoveryOwnerAddressTF: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Recovery Owner Address";
        return textField;
    }()
    
    let deviceManagerTF: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Device Manager Address";
        return textField;
    }()
    
    let userStatusTF: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "User Status";
        return textField;
    }()
    
    let deviceAddressTF: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Device Address";
        return textField;
    }()
    
    let kitEndPointTF: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Kit End Point";
        return textField;
    }()

    let deviceStatusTF: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Device Status";
        return textField;
    }()
    
    var tfControllers:[MDCTextInputControllerOutlined] = [];
    var textFields:[MDCTextField] = [];
    
    override func addSubViews() {
        textFields = [kitEndPointTF,userIdTF, userStatusTF, tokenIdTF, tokenHolderTF, deviceManagerTF,
                      recoveryAddressTF, recoveryOwnerAddressTF, deviceAddressTF, deviceStatusTF];
        for textField in textFields {
            self.addSubview(textField);
            let placeHolderText = textField.placeholder;
            textField.placeholder = "";
            let controller:MDCTextInputControllerOutlined = MDCTextInputControllerOutlined(textInput: textField);
            tfControllers.append(controller);
            controller.placeholderText = placeHolderText;
        }
    }
    
    override func addSubviewConstraints() {
        let scrollView = self;
        
        // Constraints
        var constraints = [NSLayoutConstraint]()
        var prev:MDCTextField? = nil;
        for textField in textFields {
            if ( nil == prev) {
                constraints.append(NSLayoutConstraint(item: textField,
                                                      attribute: .top,
                                                      relatedBy: .equal,
                                                      toItem: scrollView.contentLayoutGuide,
                                                      attribute: .top,
                                                      multiplier: 1,
                                                      constant: 120))
            } else {
                constraints.append(NSLayoutConstraint(item: textField,
                                                      attribute: .top,
                                                      relatedBy: .equal,
                                                      toItem: prev!,
                                                      attribute: .bottom,
                                                      multiplier: 1,
                                                      constant: 22))
            }
            constraints.append(NSLayoutConstraint(item: textField,
                                                  attribute: .centerX,
                                                  relatedBy: .equal,
                                                  toItem: scrollView,
                                                  attribute: .centerX,
                                                  multiplier: 1,
                                                  constant: 0))
            constraints.append(contentsOf:
                NSLayoutConstraint.constraints(withVisualFormat: "H:|-[textfield]-|",
                                               options: [],
                                               metrics: nil,
                                               views: [ "textfield" : textField]));
            prev = textField;
        }
        
        constraints.append(NSLayoutConstraint(item: prev!,
                                               attribute: .bottom,
                                               relatedBy: .equal,
                                               toItem: scrollView,
                                               attribute: .bottom,
                                               multiplier: 1,
                                               constant: -10))

        NSLayoutConstraint.activate(constraints);
    }
    
    override func viewDidAppearCallback() {
        super.viewDidAppearCallback();
        fillData();
        let currentUser = CurrentUser.getInstance();
        OstWalletSdk.setupDevice(userId: currentUser.ostUserId!,
                                 tokenId: currentUser.tokenId!,
                                 delegate: self.sdkInteract);
    }

    override func receivedSdkEvent(eventData: [String : Any]) {
        super.receivedSdkEvent(eventData: eventData);
        let eventType:OstSdkInteract.WorkflowEventType = eventData["eventType"] as! OstSdkInteract.WorkflowEventType;
        if ( OstSdkInteract.WorkflowEventType.flowComplete == eventType) {
            let workflowContext: OstWorkflowContext = eventData["workflowContext"] as! OstWorkflowContext
            if ( workflowContext.workflowType != OstWorkflowType.setupDevice ) {
                return;
            }
            fillData();
            self.nextButton.isHidden = false;
            self.cancelButton.isHidden = true;
            self.logsTextView.isHidden = true;
            self.activityIndicator.stopAnimating();
        }
    }
        
    func fillData() {
        do {
            let currentUser = CurrentUser.getInstance();
            let ostUser = try OstWalletSdk.getUser(currentUser.ostUserId!)
            let ostCurrentDevice = ostUser!.getCurrentDevice()
            
            kitEndPointTF.text = OstWalletSdk.getApiEndPoint()
            userIdTF.text = ostUser?.id;
            userStatusTF.text = ostUser?.status;
            tokenIdTF.text = ostUser?.tokenId;
            tokenHolderTF.text = ostUser?.tokenHolderAddress ?? "NA";
            deviceManagerTF.text = ostUser?.deviceManagerAddress ?? "NA";
            recoveryAddressTF.text = ostUser?.recoveryAddress ?? "NA";
            recoveryOwnerAddressTF.text = ostUser?.recoveryOwnerAddress ?? "NA"
            deviceAddressTF.text = ostCurrentDevice?.address;
            deviceStatusTF.text = ostCurrentDevice?.status;
            
            self.nextButton.isHidden = true;
            self.cancelButton.isHidden = true;
            self.logsTextView.isHidden = true;
        } catch let err {
            //Logger.log(message: "Some error has occoured.", parameterToPrint: err);
        }
    }
}
