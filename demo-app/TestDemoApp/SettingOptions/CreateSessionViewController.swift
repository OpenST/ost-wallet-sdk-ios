//
//  CreaateSessionViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 06/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import MaterialComponents
import OstWalletSdk

class CreateSessionViewController: BaseSettingOptionsSVViewController, UITextFieldDelegate {

    static let DEFAULT_SESSION_EXPIRES_IN: Int = 14;

    
    //MARK: - Components
    var spendingLimitTestField: MDCTextField = {
        let spendingLimitTestFiled = MDCTextField()
        spendingLimitTestFiled.translatesAutoresizingMaskIntoConstraints = false
        spendingLimitTestFiled.clearButtonMode = .never
        spendingLimitTestFiled.text = "50"
        return spendingLimitTestFiled
    }()
    var spendingLimitTestFieldController: MDCTextInputControllerOutlined? = nil
    
    var spendingUnitTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .never
        textField.placeholderLabel.text = "Unit"
        textField.text = CurrentEconomy.getInstance.tokenSymbol ?? ""
        textField.font = OstTheme.fontProvider.get(size: 15)
        return textField
    }()
    var spendingUnitTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var expiresAfterSelectedIndex:Int = DEFAULT_SESSION_EXPIRES_IN;
    var expiresAfterTextField: MDCTextField = {
        let expiresAfterTextField = MDCTextField()
        expiresAfterTextField.translatesAutoresizingMaskIntoConstraints = false
        expiresAfterTextField.clearButtonMode = .never
        expiresAfterTextField.placeholderLabel.text = "Set Expiry for Session in Days"
        expiresAfterTextField.text = "2 Weeks"
        return expiresAfterTextField
    }()
    var expirationHeightTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var createSessionButton: UIButton = {
        let button = OstUIKit.primaryButton()
        button.setTitle("Create Session", for: .normal)
        return button
        
    }()
//    var cancelButton: UIButton = {
//        let button = OstUIKit.linkButton()
//        button.setTitle("Cancel", for: .normal)
//        return button
//    }()
    
    //MARK: - Variables
    var isShowingActionSheet = false;
    
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

    //MARK: - View LC
    override func getNavBarTitle() -> String {
        return "Create Session"
    }
    override func getLeadLabelText() -> String {
        return "Authorizing a session obviates the need for the user to sign every transaction within the application thereby creating a more seamless user experience."
    }
    
    //MARK: - Add Subviews
    override func addSubviews() {
        super.addSubviews()
        setupTextFields()
        setupComponents()
        
        addSubview(spendingLimitTestField)
        addSubview(expiresAfterTextField)
        addSubview(spendingUnitTextField)
        addSubview(createSessionButton)
//        addSubview(cancelButton)
    }
    
    func setupTextFields() {
        self.spendingLimitTestFieldController = MDCTextInputControllerOutlined(textInput: spendingLimitTestField)
        self.expirationHeightTextFieldController = MDCTextInputControllerOutlined(textInput: expiresAfterTextField)
        self.spendingUnitTextFieldController = MDCTextInputControllerOutlined(textInput: spendingUnitTextField)
        
        self.spendingLimitTestFieldController!.placeholderText = "Spending Limit for Session"
        self.spendingLimitTestField.keyboardType = .numberPad
        
        self.expirationHeightTextFieldController!.placeholderText = "Set Expiry for Session in Days"
        self.expiresAfterTextField.keyboardType = .numberPad
        
        self.spendingUnitTextFieldController!.placeholderText = "Unit"
        
        self.expiresAfterTextField.delegate = self;
        self.spendingUnitTextField.delegate = self;
    }
    
    func setupComponents() {
        progressIndicator?.progressText = "Creating Session..."
        
        weak var weakSelf = self
        createSessionButton.addTarget(weakSelf, action: #selector(weakSelf!.createSessionButtonTapped(_ :)), for: .touchUpInside)
//        cancelButton.addTarget(weakSelf, action: #selector(weakSelf!.cancelButtonTapped(_ :)), for: .touchUpInside)
    }
    
    //MARK: - Add Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addSpendingLimitConstraints()
        addSpendingUitTFConstraints()
        addExpiresAfterConstraitns()
        addCreateSessionButtonConstraints()
//        addCancelButtonConstraints()
        
        let lastView = createSessionButton
        lastView.bottomAlignWithParent()

    }
    
    func addSpendingLimitConstraints() {
        spendingLimitTestField.placeBelow(toItem: leadLabel)
        spendingLimitTestField.leftAlignWithParent(multiplier: 1, constant: 20)
    }
    
    func addSpendingUitTFConstraints() {
        spendingUnitTextField.placeBelow(toItem: leadLabel)
        spendingUnitTextField.rightAlignWithParent(multiplier: 1, constant: -20)
        spendingUnitTextField.setW375Width(width: 80)
        spendingUnitTextField.leftWithRightAlign(toItem: spendingLimitTestField, multiplier: 1, constant: 20)
    }
    
    func addExpiresAfterConstraitns() {
        expiresAfterTextField.placeBelow(toItem: spendingLimitTestField)
        expiresAfterTextField.applyBlockElementConstraints()
    }
    
    func addCreateSessionButtonConstraints() {
        createSessionButton.placeBelow(toItem: expiresAfterTextField)
        createSessionButton.applyBlockElementConstraints()
    }
    
//    func addCancelButtonConstraints() {
//        cancelButton.placeBelow(toItem: createSessionButton)
//        cancelButton.applyBlockElementConstraints()
//    }
    
    
    //MARK: - Text Field Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.expiresAfterTextField {
            showExpiresAfterActionSheet();
        }
        return false;
    }
    
    func showExpiresAfterActionSheet() {
        if ( isShowingActionSheet ) {
            return;
        }
        isShowingActionSheet = true;
        let actionSheet = UIAlertController(title: "Session Validity", message: "How long should your sesstion be valid for?", preferredStyle: UIAlertController.Style.actionSheet);
        for cnt in 0..<CreateSessionViewController.DEFAULT_SESSION_EXPIRES_IN {
            let currAction = getActionForIndex(indx: cnt);
            actionSheet.addAction(currAction);
        }
        self.present(actionSheet, animated: true, completion: {
            self.isShowingActionSheet = false;
        });
    }
    
    func getActionForIndex(indx:Int) -> UIAlertAction {
        let displayText = expiresOptions[indx];
        return UIAlertAction(title: displayText, style: .default, handler: {[weak self] (UIAlertAction) in
            self?.isShowingActionSheet = false;
            self?.expiresAfterSelectedIndex = indx;
            self?.expiresAfterTextField.text = displayText;
        })
    }
    
    //MARK: - Action
    @objc func createSessionButtonTapped(_ sender: Any?) {
        
        if !isCorrectInputPassed() {
            return
        }
        
        let expireAfter = (self.expiresAfterSelectedIndex + 1) * 24 * 60 * 60;
        let finalSpendingLimit: String = OstUtils.toAtto(self.spendingLimitTestField.text!)
        OstWalletSdk.addSession(userId: CurrentUserModel.getInstance.ostUserId!,
                                spendingLimit: finalSpendingLimit,
                                expireAfterInSec: Double(expireAfter),
                                delegate: self.workflowDelegate)
        
        progressIndicator = OstProgressIndicator(textCode: .creatingSession)
        progressIndicator?.show()
    }
    
    func isCorrectInputPassed() -> Bool {
        
        if nil == self.spendingLimitTestField.text
            || self.spendingLimitTestField.text!.isEmpty
            || !self.spendingLimitTestField.text!.isMatch("^[0-9]*$") {
            
            spendingLimitTestFieldController?.setErrorText("Invalid Spending Limit",
                                                      errorAccessibilityValue: nil);
            return false;
        }
        
        spendingLimitTestFieldController?.setErrorText(nil,errorAccessibilityValue: nil);
        return true
    }
    
    @objc func cancelButtonTapped(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Workflow Delegate
    
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
    }
}
