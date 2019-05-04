//
//  SendTokensViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 04/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class SendTokensViewController: BaseSettingOptionsViewController {
    
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
    
    //MAKR: - Variables
    var userDetails: [String: Any]! {
        didSet {
            userInfoView.userData = userDetails
            userInfoView.balanceLabel?.text = userDetails["token_holder_address"] as? String ?? ""
        }
    }
    
    //MARK: - View LC
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        balanceLabel.text = "Balance: \(BalanceModel.getInstance.balance ?? "0") SPOO"
    }
    
    //MAKR: - Add Subview
    override func addSubviews() {
        super.addSubviews()
        
        setupComponents()
        
        addSubview(sendTokensLable)
        addSubview(balanceLabel)
        addSubview(userInfoView)
        addSubview(sendButton)
        addSubview(cancelButton)
    }
    
    func setupComponents() {
        progressIndicator.progressText = "Executing Transaction..."
        
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
        userInfoView.heightAnchor.constraint(equalToConstant: 65).isActive = true
    }
    
    func addSendButtonConstraints() {
        sendButton.placeBelow(toItem: userInfoView)
        sendButton.applyBlockElementConstraints()
    }
    
    func addCancelButtonConstraints() {
        cancelButton.placeBelow(toItem: sendButton)
        cancelButton.applyBlockElementConstraints()
        cancelButton.bottomAlignWithParent()
    }
    
    //MARK: - Actions
    
    @objc func sendTokenButtonTapped(_ sender: Any?) {
        progressIndicator.show()
        let tokenHolderAddress = userDetails["token_holder_address"] as! String
        OstWalletSdk.executeTransaction(userId: CurrentUser.getInstance().ostUserId!,
                                        tokenHolderAddresses: [tokenHolderAddress],
                                        amounts: ["1"],
                                        transactionType: .DirectTransfer,
                                        meta: [:],
                                        delegate: self.workflowDelegate)
    }
    
    @objc func cancelButtonTapped(_ sender: Any?) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Workflow Delegate
    
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
        progressIndicator.close()
    }
    
    override func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        super.flowInterrupted(workflowId: workflowId, workflowContext: workflowContext, error: error)
        progressIndicator.close()
    }
}
