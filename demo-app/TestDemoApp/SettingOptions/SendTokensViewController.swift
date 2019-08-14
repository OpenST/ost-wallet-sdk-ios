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
        label.font = OstTheme.fontProvider.get(size: 15).bold()
        label.textColor = UIColor.black.withAlphaComponent(0.4)
        label.text = "Send Tokens To"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    let balanceLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.font = OstTheme.fontProvider.get(size: 15)
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
        view.backgroundColor = UIColor.color(231, 243, 248)
        view.layer.cornerRadius = 6
        view.clipsToBounds = true
        
        return view
    }()
    
    var sendButton: UIButton = {
        let button = OstUIKit.primaryButton()
        button.setTitle("Send Tokens", for: .normal)
        return button
        
    }()
//    var cancelButton: UIButton = {
//        let button = OstUIKit.linkButton()
//        button.setTitle("Cancel", for: .normal)
//        return button
//    }()
    
    var tokenAmountTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .never
        textField.keyboardType = .decimalPad
        textField.placeholderLabel.text = "Amount"
        textField.font = OstTheme.fontProvider.get(size: 15)
        textField.text = "1";
        return textField
    }()
    var tokenAmountTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var tokenSpendingUnitTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .never
        textField.placeholderLabel.text = "Unit"
        textField.text = CurrentEconomy.getInstance.tokenSymbol ?? "";
        textField.font = OstTheme.fontProvider.get(size: 15)
        return textField
    }()
    var tokenSpendingUnitTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var usdAmountTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .never
        textField.keyboardType = .decimalPad
        textField.placeholderLabel.text = "Amount"
        textField.font = OstTheme.fontProvider.get(size: 15)
        return textField
    }()
    var usdAmountTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var usdSpendingUnitTextField: MDCTextField = {
        let textField = MDCTextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .never
        textField.placeholderLabel.text = "Unit"
        textField.text = "USD";
        textField.font = OstTheme.fontProvider.get(size: 15)
        return textField
    }()
    var usdSpendingUnitTextFieldController: MDCTextInputControllerOutlined? = nil
    
    //MARK: - Variables
    weak var tabbarController: TabBarViewController? = nil
    var token: OstToken? = nil
    
    var isShowingActionSheet = false;
    var isUsdTx = false
    
    var isBalanceApiInprogress = false
    var didUserTapSendTokens = false

    var userDetails: [String: Any]! {
        didSet {
            userInfoView.userData = userDetails
//            userInfoView.balanceLabel?.text = userDetails["token_holder_address"] as? String ?? ""
            userInfoView.sendButton?.isHidden = true
        }
    }
    
    //MARK: - View LC
    
    override func getNavBarTitle() -> String {
        return "Send Tokens"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
         getUserBalanceFromServer()
        tokenAmountTextField.addTarget(self,
                                  action: #selector(textFieldDidChange(textField:)),
                                  for:  UIControl.Event.editingChanged)
        usdAmountTextField.addTarget(self,
                                     action: #selector(textFieldDidChange(textField:)),
                                     for:  UIControl.Event.editingChanged)
    }
    
    func getUserBalanceFromServer() {
        if isBalanceApiInprogress {
            return
        }
        isBalanceApiInprogress = true
        
        CurrentUserModel.getInstance.fetchUserBalance {[weak self] (isSuccess, _, _) in
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
        
        let usdAmount = CurrentUserModel.getInstance.toUSD(value: tokenAmountTextField.text ?? "0") ?? "0.00"
        usdAmountTextField.text = usdAmount.toRoundUpTxValue()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tokenAmountTextField.becomeFirstResponder()
    }
    
    //MAKR: - Add Subview
    override func addSubviews() {
        super.addSubviews()
        
        setupComponents()
        
        addSubview(sendTokensLable)
        addSubview(balanceLabel)
        addSubview(userInfoView)
        addSubview(tokenAmountTextField)
        addSubview(tokenSpendingUnitTextField)
        addSubview(usdAmountTextField)
        addSubview(usdSpendingUnitTextField)
        addSubview(sendButton)
//        addSubview(cancelButton)
    }
    
    func setupComponents() {
        progressIndicator?.progressText = "Executing Transaction..."
        
        tokenAmountTextField.delegate = self
        tokenSpendingUnitTextField.delegate = self
        usdAmountTextField.delegate = self
        usdSpendingUnitTextField.delegate = self
        
        self.tokenAmountTextFieldController = MDCTextInputControllerOutlined(textInput: self.tokenAmountTextField)
        self.tokenSpendingUnitTextFieldController = MDCTextInputControllerOutlined(textInput: self.tokenSpendingUnitTextField);
        
        self.usdAmountTextFieldController = MDCTextInputControllerOutlined(textInput: self.usdAmountTextField)
        self.usdSpendingUnitTextFieldController = MDCTextInputControllerOutlined(textInput: self.usdSpendingUnitTextField);
        
        weak var weakSelf = self
        sendButton.addTarget(weakSelf, action: #selector(weakSelf!.sendTokenButtonTapped(_ :)), for: .touchUpInside)
//        cancelButton.addTarget(weakSelf, action: #selector(weakSelf!.cancelButtonTapped(_ :)), for: .touchUpInside)
    }
    
    //MAKR: - Add Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addSendTokenLabelConstraints()
        addBalanceLabelConstraints()
        addUserInfoConstraints()
        addTokenAmountTextFieldConstraints()
        addTokenUnitTextFiledConstraints()
        addUsdAmountTextFieldConstraints()
        addUsdUnitTextFiledConstraints()
        addSendButtonConstraints()
//        addCancelButtonConstraints()
        
        sendButton.bottomAlignWithParent()
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
    
    func addTokenAmountTextFieldConstraints() {
        tokenAmountTextField.placeBelow(toItem: userInfoView)
        tokenAmountTextField.leftAlignWithParent(multiplier: 1, constant: 20)
        tokenAmountTextField.setW375Width(width: 238)
    }
    
    func addTokenUnitTextFiledConstraints() {
        tokenSpendingUnitTextField.placeBelow(toItem: userInfoView)
        tokenSpendingUnitTextField.rightAlignWithParent(multiplier: 1, constant: -20)
        tokenSpendingUnitTextField.setW375Width(width: 90)
    }
    
    func addUsdAmountTextFieldConstraints() {
        usdAmountTextField.placeBelow(toItem: tokenAmountTextField, constant: 0)
        usdAmountTextField.leftAlignWithParent(multiplier: 1, constant: 20)
        usdAmountTextField.setW375Width(width: 238)
    }
    
    func addUsdUnitTextFiledConstraints() {
        usdSpendingUnitTextField.placeBelow(toItem: tokenSpendingUnitTextField, constant: 0)
        usdSpendingUnitTextField.rightAlignWithParent(multiplier: 1, constant: -20)
        usdSpendingUnitTextField.setW375Width(width: 90)
    }
    
    func addSendButtonConstraints() {
        sendButton.placeBelow(toItem: usdSpendingUnitTextField)
        sendButton.applyBlockElementConstraints()
    }
    
//    func addCancelButtonConstraints() {
//        cancelButton.placeBelow(toItem: sendButton)
//        cancelButton.applyBlockElementConstraints()
//    }
    
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
        
        var amountToTransferStr = self.tokenAmountTextField.text!
        let receiverName = userDetails["username"] as? String ?? ""
        
        let ruleType:OstExecuteTransactionType
        let progressText: String
        
//        if ( isUsdTx ) {
//            //Multiply value with 10^18. Since we have string.
//            //So: we can simply add 18 0s. [Not the best way to do it. Use BigInt]
//            ruleType = .Pay
//            progressText = "Sending $\(amountToTransferStr) to \(receiverName)"
//        }else {
            ruleType = .DirectTransfer
            progressText = "Sending \(amountToTransferStr) \(CurrentEconomy.getInstance.tokenSymbol ?? "") to \(receiverName)"
//        }
        
        amountToTransferStr = amountToTransferStr.toSmallestUnit(isUSDTx: false)
        
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
        
        if self.tokenAmountTextField.text!.isEmpty {
            isValidInput = false
        }
        
        if isValidInput,
            var userBalance: Double = Double(CurrentUserModel.getInstance.balance),
            let enteredAmount: Double = Double(self.tokenAmountTextField.text!) {
            
            if isUsdTx {
                let usdBalance = getUserUSDBalance()
                userBalance = Double(usdBalance)!
            }
            if enteredAmount > userBalance {
                isValidInput = false
            }
        }
        
        if isValidInput {
            tokenAmountTextFieldController?.setErrorText(nil,errorAccessibilityValue: nil);
        } else {
            tokenAmountTextFieldController?.setErrorText("Low balance to make this transaction",
                                                    errorAccessibilityValue: nil);
        }
        
        return isValidInput
    }
    
    
    @objc func cancelButtonTapped(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - TextField Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if ( tokenSpendingUnitTextField == textField
            || usdSpendingUnitTextField == textField) {
//            if  !isShowingActionSheet {
//                showUnitActionSheet();
//            }
            return false;
        }
        return true;
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        tokenAmountTextFieldController?.setErrorText(nil,errorAccessibilityValue: nil);
        if (string == "." || string == ",")
            && ((textField.text ?? "").contains(".")
                || (textField.text ?? "").contains(",")) {
            return false
        }
        
        return true
    }
    
    @objc func textFieldDidChange(textField: UITextField) {
        var text = textField.text ?? "0"
        text = text.replacingOccurrences(of: ",", with: ".")
        
        textField.text = text
        
        let values = text.components(separatedBy: ".")
        
        if values.count == 2
            && values[1].count > 0{
            
            textField.text = text.toDisplayTxValue()
        }
        
        if textField == tokenAmountTextField {
            let usdAmount = CurrentUserModel.getInstance.toUSD(value: text) ?? "0.00"
            usdAmountTextField.text = usdAmount.toRoundUpTxValue()
        }
        else if textField == usdAmountTextField {
            let transferVal = text.toSmallestUnit(isUSDTx: true)
            let finalVal = CurrentUserModel.getInstance.toBt(value: transferVal)
            tokenAmountTextField.text = finalVal?.toRedableFormat().toRoundUpTxValue()
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
            self?.tokenSpendingUnitTextField.text = CurrentEconomy.getInstance.tokenSymbol ?? "";
            self?.isUsdTx = false
            self?.updateUserBalanceUI()
            
        });
        actionSheet.addAction(directTransafer);
        
        let pricer = UIAlertAction(title: "USD", style: .default, handler: {[weak self] (UIAlertAction) in
            self?.isShowingActionSheet = false;
            self?.tokenSpendingUnitTextField.text = "USD";
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
        showSuccessAlert(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
    }
    
    override func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.flowComplete(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
    }
    
    override func showSuccessAlert(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if workflowContext.workflowType == .executeTransaction {
            progressIndicator?.showSuccessAlert(forWorkflowType: workflowContext.workflowType,
                                                onCompletion: {[weak self] (_) in
                self?.onFlowComplete(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
            })
        }
    }
    
    override func onFlowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.onFlowComplete(workflowId: workflowId,
                             workflowContext: workflowContext,
                             contextEntity: contextEntity)
        
        self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1, execute: {
            self.tabbarController?.jumpToWalletVC(withWorkflowId: workflowId)
        })
    }
    
    override func showFailureAlert(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        progressIndicator?.hide()
        progressIndicator = nil
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
