//
//  AuthorizeDeviceViaMnemonicsViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 01/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import MaterialComponents
import OstWalletSdk


class AuthorizeDeviceViaMnemonicsViewController: BaseSettingOptionsSVViewController {
    
    var subscribeToCallback: ((OstWorkflowCallbacks) ->Void)? = nil
    
    //MAKR: - Components
    let wordsTextView: MDCMultilineTextField = {
        let wordsTextView = MDCMultilineTextField()
        wordsTextView.translatesAutoresizingMaskIntoConstraints = false
        wordsTextView.isEnabled = true;
        wordsTextView.clearButtonMode = .never
        wordsTextView.minimumLines = 3;
        return wordsTextView
    }()
    var wordsTextController:MDCTextInputControllerOutlinedTextArea? = nil;
    
    let recoverWalletButton: UIButton = {
        let button = OstUIKit.primaryButton()
        button.setTitle("Recover Wallet!", for: .normal)
        
        return button
    }()
    
    //MARK: - View LC
    override func getNavBarTitle() -> String {
        return "Enter 12-word Mnemonic"
    }
    
    override func getLeadLabelText() -> String {
        return "Please enter the 12-word mnemonic phrase that you wrote down. If you don’t have the mnemonic phrase, try using PIN or a second authorized device."
    }
    
    //MARK: - Add Subviews
    override func addSubviews() {
        super.addSubviews()
        self.wordsTextController = MDCTextInputControllerOutlinedTextArea(textInput: wordsTextView);
        self.wordsTextController?.placeholderText = "Enter mnemonic Phrase…"
        
        addSubview(wordsTextView)
        addSubview(recoverWalletButton)
        
        weak var weakSelf = self
        recoverWalletButton.addTarget(weakSelf, action: #selector(weakSelf!.recoverWalletButtonTapped(_:)), for: .touchUpInside)
    }
    
    //MARK: - Add Layout Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addTextFiledLayoutConstraints()
        addRecoverWalletButtonConstraints()
    }
    
    func addTextFiledLayoutConstraints() {
        wordsTextView.placeBelow(toItem: leadLabel, constant: 22)
        wordsTextView.centerXAlignWithParent()
        wordsTextView.setAspectRatio(width: 325, height: 133);
    }
    
    func addRecoverWalletButtonConstraints() {
        recoverWalletButton.placeBelow(toItem: wordsTextView)
        recoverWalletButton.centerXAlignWithParent()
        recoverWalletButton.setW375Width(width: 315)
        recoverWalletButton.setAspectRatio(width: 315, height: 50)
        recoverWalletButton.bottomAlignWithParent()
    }
    
    //MARK: - Button Action
    
    @objc func recoverWalletButtonTapped(_ sender: Any?) {
        
        if !isValidInput() {
            return
        }
        let currentUser = CurrentUserModel.getInstance
        let mnemonics: [String] = self.wordsTextView.text!.components(separatedBy: " ")
        
        let workflowDelegate = self.workflowDelegate
        subscribeToCallback?(workflowDelegate)
        progressIndicator = OstProgressIndicator(textCode: .authorizingDevice)
        progressIndicator?.show()
        OstWalletSdk.authorizeCurrentDeviceWithMnemonics(userId: currentUser.ostUserId!,
                                                         mnemonics: mnemonics,
                                                         delegate: workflowDelegate)
    }
    
    func isValidInput() -> Bool {
        var mnemonics: [String] = self.wordsTextView.text!.components(separatedBy: " ")
        mnemonics = mnemonics.filter({
            let text = $0.replacingOccurrences(of: " ", with: "")
            return !text.isEmpty
        })
        
        if mnemonics.count == 12 {
            wordsTextController?.setErrorText(nil,errorAccessibilityValue: nil);
            return true
        }
        
        wordsTextController?.setErrorText("Invalid Mnemonics passed.",
                                          errorAccessibilityValue: nil);
        return false
    }
    
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        progressIndicator?.hide()
        progressIndicator = nil
    }
    
    override func showSuccessAlert(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        progressIndicator?.hide()
        progressIndicator = nil
    }
}
