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
        textField.keyboardType = .decimalPad
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
    
    var isBalanceApiInprogress = false
    var didUserTapSendTokens = false

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserBalanceFromServer()
        amountTextField.addTarget(self,
                                  action: #selector(textFieldDidChange(textField:)),
                                  for:  UIControl.Event.editingChanged)
    }
    
    func getUserBalanceFromServer() {
        if isBalanceApiInprogress {
            return
        }
        isBalanceApiInprogress = true
        UserAPI.getCurrentUserBalance(onSuccess: {[weak self] (_) in
            self?.onRequestComplete()
        }) {[weak self] (_) in
            self?.onRequestComplete()
        }
    }
    
    @objc func onRequestComplete() {
        updateUserBalanceUI()
        isBalanceApiInprogress = false
        if didUserTapSendTokens {
            didUserTapSendTokens = false
            self.perform(#selector(sendTokenButtonTapped(_ :)), with: nil, afterDelay: 0.3)
        }
    }
    
    func updateUserBalanceUI() {
        let currentUse = CurrentUserModel.getInstance
        let currentEconomy = CurrentEconomy.getInstance
        if isUsdTx {
            let usdBalance = self.getUserUSDBalance()
            balanceLabel.text = "Balance: $ \(usdBalance.toDisplayTxValue())"
        }else {
            balanceLabel.text = "Balance: \(currentUse.balance) \(currentEconomy.tokenSymbol ?? "")"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUserBalanceUI()
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
        
        if isBalanceApiInprogress && isUsdTx {
            didUserTapSendTokens = true
            progressIndicator = OstProgressIndicator(textCode: .fetchingUserBalance)
            progressIndicator?.show()
            return
        }
        progressIndicator?.hide()
        progressIndicator = nil
        
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
        }
        
        amountToTransferStr = amountToTransferStr.toSmallestUnit(isUSDTx: isUsdTx)
        
        progressIndicator = OstProgressIndicator(progressText: progressText)
        getApplicationWindow()?.addSubview(progressIndicator!)
        progressIndicator?.show()
        
        var txMeta: [String: String] = [:];
        txMeta["type"] = "user_to_user";
        txMeta["name"] = "Tokens sent from iOS";
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
        
        if self.amountTextField.text!.isEmpty {
            isValidInput = false
        }
        
        if isValidInput,
            var userBalance: Double = Double(CurrentUserModel.getInstance.balance),
            let enteredAmount: Double = Double(self.amountTextField.text!) {
            
            if isUsdTx {
                let usdBalance = getUserUSDBalance()
                userBalance = Double(usdBalance)!
            }
            if enteredAmount > userBalance {
                isValidInput = false
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
        if ( spendingUnitTextField == textField ) {
            if  !isShowingActionSheet {
                showUnitActionSheet();
            }
            return false;
        }
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        amountTextFieldController?.setErrorText(nil,errorAccessibilityValue: nil);
        if string == "." && (textField.text ?? "").contains(string) {
            return false
        }
        if string == "," {
            return false
        }
        return true
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        let text = textField.text ?? ""
        let values = text.components(separatedBy: ".")
        
        if values.count == 2
            && values[1].count > 0{
            
            textField.text = text.toDisplayTxValue()
        }
    }
    
    func showUnitActionSheet() {
        if ( isShowingActionSheet ) {
            //return;
        }
        isShowingActionSheet = true;
        let actionSheet = UIAlertController(title: "Select Transfer Currency", message: "Please choose the currency to price transaction. Choosing USD will mean that the chosen number of USD worth of tokens will be transferred.", preferredStyle: UIAlertController.Style.actionSheet);
        
        let directTransafer = UIAlertAction(title: CurrentEconomy.getInstance.tokenSymbol ?? "BT", style: .default, handler: {[weak self] (UIAlertAction) in
            self?.isShowingActionSheet = false;
            self?.spendingUnitTextField.text = CurrentEconomy.getInstance.tokenSymbol ?? "";
            self?.isUsdTx = false
            self?.updateUserBalanceUI()
            
        });
        actionSheet.addAction(directTransafer);
        
        let pricer = UIAlertAction(title: "USD", style: .default, handler: {[weak self] (UIAlertAction) in
            self?.isShowingActionSheet = false;
            self?.spendingUnitTextField.text = "USD";
            self?.isUsdTx = true
            self?.updateUserBalanceUI()
        });
        actionSheet.addAction(pricer);
        
        self.present(actionSheet, animated: true, completion: {
            self.isShowingActionSheet = false;
        });
    }
    
    //MARK: - Workflow Delegate
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
        progressIndicator?.progressText = "Transaction processing..."
    }
    
    override func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.flowComplete(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
    }
    
    override func showSuccessAlert(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if workflowContext.workflowType == .executeTransaction {
            progressIndicator?.showSuccessAlert(forWorkflowType: workflowContext.workflowType,
                                                actionButtonTitle: "View Details",
                                                actionButtonTapped: {[weak self] (_) in
                                     
                                                  self?.showWebViewForTransaction()
                                                    
            }, onCompletion: nil)
        }
    }
    
    func showWebViewForTransaction() {
        progressIndicator = nil
        CurrentUserModel.getInstance.showTokenHolderInView()
    }
    
    func getUserUSDBalance() -> String {
        let currentUser = CurrentUserModel.getInstance
        let usdBalance = currentUser.toUSD(value: currentUser.balance) ?? "0.00"
        return usdBalance
    }
}
