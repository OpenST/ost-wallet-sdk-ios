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
class SendTokensToUserView: BaseWalletWorkflowView, UITextFieldDelegate {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @objc override func didTapNext(sender: Any) {
        super.didTapNext(sender: sender);
        let currentUser = CurrentUser.getInstance();
        var amountToTransferStr = self.amountTextField.text!;
        
        if ( isEthTx ) {
            //Multiply value with 10^18. Since we have string.
            //So: we can simply add 18 0s. [Not the best way to do it. Use BigInt]
            amountToTransferStr = amountToTransferStr + "000000000000000000";
        }
        
        var txMeta:[String: String] = [:];
        var reveiverAddressStr = "";
        if ( nil != receiverAddress.text ) {
            reveiverAddressStr = receiverAddress.text!
        }
        
        if ( nil != toUser) {
            txMeta["type"] = "user_to_user";
            txMeta["name"] = "known_user";
            //Let's build some json. Not the best way do it, but, works here.
            txMeta["details"] = "Sending to \(toUser!.displayName!)";
        } else {
            //Don't Populate type, if you are not sure.
            txMeta["name"] = "unknown_user";
            var customDescription = "Token tranfer to custom address.";
            
            //Don't worry. toUserName acts as description in this case.
            if ( nil != toUserName.text && toUserName.text!.count > 1 ) {
                customDescription = toUserName.text!;
            }
            txMeta["details"] = "Sending to \(customDescription)"
        }
        
        var ruleType:OstExecuteTransactionType;
        if ( isDirectTransfer ) {
            ruleType = OstExecuteTransactionType.DirectTransfer;
        } else {
            ruleType = OstExecuteTransactionType.Pay;
        }
            
        OstWalletSdk.executeTransaction(userId: currentUser.ostUserId!,
                                                   tokenHolderAddresses: [reveiverAddressStr],
                                                   amounts: [amountToTransferStr],
                                                   transactionType: ruleType,
                                                   meta: txMeta,
                                                   delegate: self.workflowCallback);
    }
    
    
    
    
    
    // Mark - Sub Views
    let toUserName: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Receiver Name";
        return textField;
    }()
    var toUserNameController: MDCTextInputControllerOutlined? = nil
    
    let receiverAddress: MDCTextField = {
        let textField = MDCTextField();
        textField.translatesAutoresizingMaskIntoConstraints = false;
        textField.placeholderLabel.text = "Receiver Address";
        return textField;
    }()
    var receiverAddressController: MDCTextInputControllerOutlined? = nil
    
    var amountTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .never
        textField.placeholderLabel.text = "Amount"
        textField.text = "1";
        return textField
    }()
    var amountTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var isDirectTransfer = true
    var currencyTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .never
        textField.placeholderLabel.text = "Rule"
        textField.text = "BT";
        return textField
    }()
    var currencyTextFieldController: MDCTextInputControllerOutlined? = nil

    var isEthTx = false
    var spendingUnitTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .never
        textField.placeholderLabel.text = "Unit"
        textField.text = CurrentEconomy.getInstance.tokenSymbol ?? ""
        return textField
    }()
    var spendingUnitTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var amountSlider: UISlider = {
        let slider = UISlider();
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.thumbTintColor = UIColor.init(red: 52.0/255.0, green: 68.0/255.0, blue: 91.0/255.0, alpha: 1.0);
        slider.maximumTrackTintColor = UIColor.init(red: 39.0/255.0, green: 184.0/255.0, blue: 210.0/255.0, alpha: 1.0);
        slider.minimumTrackTintColor = UIColor.init(red: 67.0/255.0, green: 139.0/255.0, blue: 173.0/255.0, alpha: 1.0);
        
        return slider;
    }()
    
    override func addSubViews() {
        let scrollView = self;

        scrollView.addSubview(self.toUserName)
        self.toUserNameController = MDCTextInputControllerOutlined(textInput: self.toUserName)

        scrollView.addSubview(self.receiverAddress)
        self.receiverAddressController = MDCTextInputControllerOutlined(textInput: self.receiverAddress)

        scrollView.addSubview(amountSlider)
        
        scrollView.addSubview(self.amountTextField)
        self.amountTextFieldController = MDCTextInputControllerOutlined(textInput: self.amountTextField)
        
        scrollView.addSubview(self.currencyTextField)
        self.currencyTextFieldController = MDCTextInputControllerOutlined(textInput: self.currencyTextField)
        
        scrollView.addSubview(self.spendingUnitTextField)
        self.spendingUnitTextFieldController = MDCTextInputControllerOutlined(textInput: self.spendingUnitTextField);
        
        super.addSubViews();
        //    MDCTextFieldColorThemer.apply(ApplicationScheme.shared.colorScheme, to: self.wordsTextController);
        self.nextButton.setTitle("Transfer", for: .normal);
        
        
        toUserName.delegate = self
        currencyTextField.delegate = self
        spendingUnitTextField.delegate = self
        receiverAddress.delegate = self
        amountTextField.delegate = self
        amountSlider.addTarget(self, action: #selector(amountUpdated(sender:)), for: .valueChanged);
        
        super.cancelButton.setTitle("Cancel", for: .normal);
    }

    override func addSubviewConstraints() {
        let scrollView = self;

        // Constraints
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: toUserName,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: scrollView.contentLayoutGuide,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: 100))
        constraints.append(NSLayoutConstraint(item: toUserName,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: scrollView,
                                                attribute: .leading,
                                                multiplier: 1,
                                                constant: 10))
        
        constraints.append(NSLayoutConstraint(item: toUserName,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: scrollView,
                                                attribute: .trailing,
                                                multiplier: 1,
                                                constant: -10))
        
        constraints.append(NSLayoutConstraint(item: receiverAddress,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: toUserName,
                                                attribute: .bottom,
                                                multiplier: 1,
                                                constant: 20))
        
        constraints.append(NSLayoutConstraint(item: receiverAddress,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: scrollView,
                                                attribute: .leading,
                                                multiplier: 1,
                                                constant: 10))
        
        constraints.append(NSLayoutConstraint(item: receiverAddress,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: scrollView,
                                                attribute: .trailing,
                                                multiplier: 1,
                                                constant: -10))

        constraints.append(NSLayoutConstraint(item: amountSlider,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: receiverAddress,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 20))
        
        constraints.append(NSLayoutConstraint(item: amountSlider,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 10))
        
        constraints.append(NSLayoutConstraint(item: amountSlider,
                                              attribute: .trailing,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .trailing,
                                              multiplier: 1,
                                              constant: -10))
        
        constraints.append(NSLayoutConstraint(item: amountTextField,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: amountSlider,
                                              attribute: .bottom,
                                              multiplier: 1,
                                              constant: 20))

        constraints.append(NSLayoutConstraint(item: amountTextField,
                                              attribute: .leading,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .leading,
                                              multiplier: 1,
                                              constant: 10))

        constraints.append(NSLayoutConstraint(item: currencyTextField,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: amountTextField,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: 0))
        
        constraints.append(NSLayoutConstraint(item: currencyTextField,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: amountTextField,
                                                attribute: .trailing,
                                                multiplier: 1,
                                                constant: 20))
        
        constraints.append(NSLayoutConstraint(item: spendingUnitTextField,
                                                attribute: .top,
                                                relatedBy: .equal,
                                                toItem: amountTextField,
                                                attribute: .top,
                                                multiplier: 1,
                                                constant: 0))

        constraints.append(NSLayoutConstraint(item: spendingUnitTextField,
                                                attribute: .leading,
                                                relatedBy: .equal,
                                                toItem: currencyTextField,
                                                attribute: .trailing,
                                                multiplier: 1,
                                                constant: 20))

        constraints.append(NSLayoutConstraint(item: spendingUnitTextField,
                                                attribute: .trailing,
                                                relatedBy: .equal,
                                                toItem: scrollView,
                                                attribute: .trailing,
                                                multiplier: 1,
                                                constant: -10))
        
        constraints.append(NSLayoutConstraint(item: amountTextField,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: spendingUnitTextField,
                                              attribute: .width,
                                              multiplier: 2,
                                              constant: 0))
        
        constraints.append(NSLayoutConstraint(item: spendingUnitTextField,
                                              attribute: .width,
                                              relatedBy: .equal,
                                              toItem: currencyTextField,
                                              attribute: .width,
                                              multiplier: 1,
                                              constant: 0))

        super.addBottomSubviewConstraints(afterView:spendingUnitTextField, constraints: constraints);
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if ( currencyTextField == textField && !isShowingActionSheet ) {
            showCurrencyActionSheet();
            return false;
        } else if ( spendingUnitTextField == textField && !isShowingActionSheet ) {
            showUnitActionSheet();
            return false;
        } else if ( amountTextField == textField ) {
            return false;
        }
        return true;
    }
    
    var isShowingActionSheet = false;
    func showCurrencyActionSheet() {
        if ( isShowingActionSheet ) {
            //return;
        }
        isShowingActionSheet = true;
        let actionSheet = UIAlertController(title: "Select Rule", message: "Select Your Transaction Rule", preferredStyle: UIAlertController.Style.actionSheet);
        
        let directTransafer = UIAlertAction(title: "Direct Transfer - Amount in BT", style: .default, handler: { (UIAlertAction) in
            self.currencyTextField.text = "BT";
            self.isDirectTransfer = true
        });
        actionSheet.addAction(directTransafer);

        let pricer = UIAlertAction(title: "Pricer - Amount in USD", style: .default, handler: { (UIAlertAction) in
            self.currencyTextField.text = "USD";
            self.isDirectTransfer = false
        });
        actionSheet.addAction(pricer);
        
        self.walletViewController?.present(actionSheet, animated: true, completion: {
            self.isShowingActionSheet = false;
        });
    }
    
    func showUnitActionSheet() {
        if ( isShowingActionSheet ) {
            //return;
        }
        isShowingActionSheet = true;
        let actionSheet = UIAlertController(title: "Select Rule", message: "Select Your Transaction Rule", preferredStyle: UIAlertController.Style.actionSheet);
        
        let directTransafer = UIAlertAction(title: "Atto BT [10^(-18)]", style: .default, handler: { (UIAlertAction) in
            self.spendingUnitTextField.text = "Atto BT";
            self.isEthTx = false
        });
        actionSheet.addAction(directTransafer);
        
        let pricer = UIAlertAction(title: "Eth [1]", style: .default, handler: { (UIAlertAction) in
            self.spendingUnitTextField.text = "Eth";
            self.isEthTx = true
        });
        actionSheet.addAction(pricer);
        
        self.walletViewController?.present(actionSheet, animated: true, completion: {
            self.isShowingActionSheet = false;
        });
    }
    
    var toUser:User? = nil
    func isUserMode() -> Bool {
        return nil != toUser;
    }
    public func setToUser(toUser:User?) {
        self.toUser = toUser;
        if ( isUserMode() ) {
            toUserName.text = toUser?.displayName
            receiverAddress.text = toUser?.tokenHolderAddress
            toUserName.clearButtonMode = UITextField.ViewMode.never
            receiverAddress.clearButtonMode = UITextField.ViewMode.never
        } else {
            toUserName.placeholderLabel.text = "Mata-details-value"
            toUserName.text = "Token transfer to known addess."
        }
    }
    
    @objc func amountUpdated(sender: UISlider) {
        let max_value = Float(500)
        var sliderIntValue = Int( sender.value * max_value );
        if ( sliderIntValue < 1 ) {
            sliderIntValue = 1;
        }
        self.amountTextField.text = String(sliderIntValue);
    }
}
