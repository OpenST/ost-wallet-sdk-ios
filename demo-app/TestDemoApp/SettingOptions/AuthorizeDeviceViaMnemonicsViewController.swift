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


class AuthorizeDeviceViaMnemonicsViewController: BaseSettingOptionsViewController {
    
    //MAKR: - Components
    let wordsTextView: MDCMultilineTextField = {
        let wordsTextView = MDCMultilineTextField()
        wordsTextView.translatesAutoresizingMaskIntoConstraints = false
        wordsTextView.isEnabled = true;
        wordsTextView.minimumLines = 3;
        return wordsTextView
    }()
    var wordsTextController:MDCTextInputControllerOutlinedTextArea? = nil;
    
    let recoverWalletButton: UIButton = {
        let button = OstUIKit.primaryButton()
        button.setTitle("Recover Wallet!", for: .normal)
        
        return button
    }()
    
    var progressIndicator: OstProgressIndicator =  OstProgressIndicator(progressText: "Recovering your Wallet")
    
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
        addSubview(progressIndicator)
        
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
        progressIndicator.show()
        let currentUser = CurrentUser.getInstance()
        let mnemonics: [String] = self.wordsTextView.text!.components(separatedBy: " ")
        OstWalletSdk.authorizeCurrentDeviceWithMnemonics(userId: currentUser.ostUserId!,
                                                         mnemonics: mnemonics,
                                                         delegate: self.workflowDelegate)
    }
    
    //MARK: - Workflow delegate
    
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
        progressIndicator.close()
    }
    
    override func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        super.flowInterrupted(workflowId: workflowId, workflowContext: workflowContext, error: error)
        progressIndicator.close()

    }
}
