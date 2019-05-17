//
//  SendTokensViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 04/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk
import MaterialComponents

class SendTokensViewController: BaseSettingOptionsSVViewController, UITextFieldDelegate {
    
    //MAKR: - Components
    let sendTokensLable: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = OstFontProvider().get(size: 15)
        label.textColor = UIColor.black.withAlphaComponent(0.4)
        label.text = "Send Tokens To"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let balanceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = OstFontProvider().get(size: 15)
        label.textColor = UIColor.color(89, 122, 132)
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var userInfoView: UsersTableViewCell = {
        let view = UsersTableViewCell()
        
        view.sendButton?.isHidden = true
        view.sendButton?.setTitle("", for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.seperatorLine?.isHidden = true
        view.backgroundColor = UIColor.color(239, 249, 250)
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        
        return view
    }()
    
    var sendButton: UIButton = {
        let button = OstUIKit.primaryButton()
        button.setTitle("Send Tokens", for: .normal)
        return button
        
    }()
    var cancelButton: UIButton = {
        let button = OstUIKit.secondaryButton()
        button.setTitle("Cancel", for: .normal)
        return button
    }()
    
    var amountTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .never
        textField.keyboardType = .numberPad
        textField.placeholderLabel.text = "Amount"
        textField.font = OstFontProvider().get(size: 15)
        textField.text = "1";
        return textField
    }()
    var amountTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var spendingUnitTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .never
        textField.placeholderLabel.text = "Unit"
        textField.text = CurrentEconomy.getInstance.tokenSymbol ?? "";
        textField.font = OstFontProvider().get(size: 15)
        return textField
    }()
    var spendingUnitTextFieldController: MDCTextInputControllerOutlined? = nil
    
    //MAKR: - Variables
    var isShowingActionSheet = false;
    var isUsdTx = false

    var userDetails: [String: Any]! {
        didSet {
            userInfoView.userData = userDetails
            userInfoView.balanceLabel?.text = userDetails["token_holder_address"] as? String ?? ""
        }
    }
    
    //MARK: - View LC
    
    override func getNavBarTitle() -> String {
        return "Send Tokens"
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let currentUse = CurrentUserModel.getInstance
        let currentEconomy = CurrentEconomy.getInstance
        balanceLabel.text = "Balance: \(currentUse.balance) \(currentEconomy.tokenSymbol ?? "")"
    }
    
    //MAKR: - Add Subview
    override func addSubviews() {
        super.addSubviews()
        
        setupComponents()
        
        addSubview(sendTokensLable)
        addSubview(balanceLabel)
        addSubview(userInfoView)
        addSubview(amountTextField)
        addSubview(spendingUnitTextField)
        addSubview(sendButton)
        addSubview(cancelButton)
    }
    
    func setupComponents() {
        progressIndicator?.progressText = "Executing Transaction..."

        amountTextField.delegate = self
        spendingUnitTextField.delegate = self
        
        self.amountTextFieldController = MDCTextInputControllerOutlined(textInput: self.amountTextField)
        self.spendingUnitTextFieldController = MDCTextInputControllerOutlined(textInput: self.spendingUnitTextField);

        weak var weakSelf = self
        sendButton.addTarget(weakSelf, action: #selector(weakSelf!.sendTokenButtonTapped(_ :)), for: .touchUpInside)
        cancelButton.addTarget(weakSelf, action: #selector(weakSelf!.cancelButtonTapped(_ :)), for: .touchUpInside)
    }
    
    //MAKR: - Add Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addSendTokenLabelConstraints()
        addBalanceLabelConstraints()
        addUserInfoConstraints()
        addAmountTextFieldConstraints()
        addUnitTextFiledConstraints()
        addSendButtonConstraints()
        addCancelButtonConstraints()
    }
    
    func addSendTokenLabelConstraints() {
        sendTokensLable.topAlignWithParent(multiplier: 1, constant: 20)
        sendTokensLable.leftAlignWithParent(multiplier: 1, constant: 20)
    }
    
    func addBalanceLabelConstraints() {
        balanceLabel.topAlignWithParent(multiplier: 1, constant: 20)
        balanceLabel.rightAlignWithParent(multiplier: 1, constant: -20)
        balanceLabel.leftWithRightAlign(toItem: sendTokensLable, constant: 8)
    }
    
    func addUserInfoConstraints() {
        userInfoView.placeBelow(toItem: sendTokensLable)
        userInfoView.applyBlockElementConstraints()
        userInfoView.heightAnchor.constraint(equalToConstant: 70).isActive = true
    }
    
    func addAmountTextFieldConstraints() {
        amountTextField.placeBelow(toItem: userInfoView)
        amountTextField.leftAlignWithParent(multiplier: 1, constant: 20)
        amountTextField.setW375Width(width: 238)
    }
    
    func addUnitTextFiledConstraints() {
        spendingUnitTextField.placeBelow(toItem: userInfoView)
        spendingUnitTextField.rightAlignWithParent(multiplier: 1, constant: -20)
        spendingUnitTextField.setW375Width(width: 90)
    }
    
    func addSendButtonConstraints() {
        sendButton.placeBelow(toItem: amountTextField)
        sendButton.applyBlockElementConstraints()
    }
    
    func addCancelButtonConstraints() {
        cancelButton.placeBelow(toItem: sendButton)
        cancelButton.applyBlockElementConstraints()
        cancelButton.bottomAlignWithParent()
    }
    
    //MARK: - Actions
    
    @objc func sendTokenButtonTapped(_ sender: Any?) {
        
        if !isValidInputPassed() {
            return
        }
        
        var amountToTransferStr = self.amountTextField.text!
        let receiverName = userDetails["username"] as? String ?? ""
        
        let ruleType:OstExecuteTransactionType
        let progressText: String
        
        if ( isUsdTx ) {
            //Multiply value with 10^18. Since we have string.
            //So: we can simply add 18 0s. [Not the best way to do it. Use BigInt]
            ruleType = .Pay
            progressText = "Sending $\(amountToTransferStr) to \(receiverName)"
        }else {
            ruleType = .DirectTransfer
            progressText = "Sending \(amountToTransferStr) \(CurrentEconomy.getInstance.tokenSymbol ?? "") to \(receiverName)"
            amountToTransferStr = amountToTransferStr + "000000000000000000"
        }
        
        progressIndicator = OstProgressIndicator(progressText: progressText)
        getApplicationWindow()?.addSubview(progressIndicator!)
        progressIndicator?.show()
        
        var txMeta: [String: String] = [:];
            txMeta["type"] = "user_to_user";
            txMeta["name"] = "Sent to \(receiverName)";
            //Let's build some json. Not the best way do it, but, works here.
            txMeta["details"] = "Received from \(CurrentUserModel.getInstance.userName ?? "")";
        
        let tokenHolderAddress = userDetails["token_holder_address"] as! String
        OstWalletSdk.executeTransaction(userId: CurrentUserModel.getInstance.ostUserId!,
                                        tokenHolderAddresses: [tokenHolderAddress],
                                        amounts: [amountToTransferStr],
                                        transactionType: ruleType,
                                        meta: txMeta,
                                        delegate: self.workflowDelegate)
    }
    
    func isValidInputPassed() -> Bool {
        var isValidInput: Bool = true
        if let userBalance: Double = Double(CurrentUserModel.getInstance.balance),
            let enteredAmount: Double = Double(self.amountTextField.text!) {
            
            if isUsdTx {
                
            }else {
                if enteredAmount > userBalance {
                    isValidInput = false
                }
            }
        }
        
        if isValidInput {
            amountTextFieldController?.setErrorText(nil,errorAccessibilityValue: nil);
        } else {
            amountTextFieldController?.setErrorText("Low balance to make this transaction",
                                                errorAccessibilityValue: nil);
        }
       
        return isValidInput
    }
        
    
    @objc func cancelButtonTapped(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if ( spendingUnitTextField == textField && !isShowingActionSheet ) {
            showUnitActionSheet();
            return false;
        }
        return true;
    }
    
    func showUnitActionSheet() {
        if ( isShowingActionSheet ) {
            //return;
        }
        isShowingActionSheet = true;
        let actionSheet = UIAlertController(title: "Select Rule", message: "Select Your Transaction Rule", preferredStyle: UIAlertController.Style.actionSheet);
        
        let directTransafer = UIAlertAction(title: "BT", style: .default, handler: { (UIAlertAction) in
            self.spendingUnitTextField.text = CurrentEconomy.getInstance.tokenSymbol ?? "";
            self.isUsdTx = false
        });
        actionSheet.addAction(directTransafer);
        
        let pricer = UIAlertAction(title: "USD", style: .default, handler: { (UIAlertAction) in
            self.spendingUnitTextField.text = "USD";
            self.isUsdTx = true
        });
        actionSheet.addAction(pricer);
        
        self.present(actionSheet, animated: true, completion: {
            self.isShowingActionSheet = false;
        });
    }
    
    //MARK: - Workflow Delegate
    
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
        progressIndicator?.hide(onCompletion: {[weak self] (isCompleted) in
            self?.showRequestAcknowledgedAlert()
        })
    }
    
    override func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        super.flowInterrupted(workflowId: workflowId, workflowContext: workflowContext, error: error)
        progressIndicator?.hide()
    }
    
    func showRequestAcknowledgedAlert() {
        let alert = UIAlertController(title: """



            Your Transaction has been broadcasted
            """,
                                      message: nil,
                                      preferredStyle: .alert)
        
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "transactionCheckmark")
        
        alert.view.addSubview(imageView)
        
        let parent = imageView.superview!
        imageView.topAnchor.constraint(equalTo: parent.topAnchor, constant: 28).isActive = true
        imageView.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}
