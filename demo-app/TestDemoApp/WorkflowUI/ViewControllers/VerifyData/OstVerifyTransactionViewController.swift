/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit
import OstWalletSdk

class OstVerifyTransactionViewController: OstBaseScrollViewController {
    
    var tokenHolderAddress: [String]? = nil
    /// Atto Value Array
    var transferAmounts: [String]? = nil
    var ruleName: String? = nil
    var delegate: OstBaseDelegate?
    
    //MARK: - View LC
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        var transferBalance: Double = Double(0)
        
        if nil != tokenHolderAddress && tokenHolderAddress!.count > 0 {
            let transferAmounts = self.transferAmounts ?? []
            
            for (index, transferAddress) in tokenHolderAddress!.enumerated() {
                var amount = "0"
                if transferAmounts.count > index {
                    amount = transferAmounts[index]
                    amount = OstUtils.fromAtto(amount)
                    amount = amount.displayTransactionValue()
                    transferBalance += Double(amount)!
                }
                let transfer = getTransferView(forAddress: transferAddress, withValue: amount)
                
                stackView.addArrangedSubview(transfer)
            }
        }
        
        self.balanceLabel.text = "Balance: \(CurrentUserModel.getInstance.balance) \(CurrentEconomy.getInstance.tokenSymbol ?? "")"
        
        if ruleName?.caseInsensitiveCompare(OstExecuteTransactionType.DirectTransfer.rawValue) == .orderedSame {
            self.ruleNameValueLabel.text = "Direct Transfer"

            validateBalanceForDirectTransfer(transferBalance: transferBalance)
        }
        else if ruleName?.caseInsensitiveCompare(OstExecuteTransactionType.Pay.rawValue) == .orderedSame {
            self.ruleNameValueLabel.text = "Pricer"
            
            validateBalanceForPricer(transferBalance: transferBalance)
        }
    }
    
    func validateBalanceForDirectTransfer(transferBalance: Double) {
        
        let availableBalance = Double(CurrentUserModel.getInstance.balance)!
        if transferBalance <= availableBalance {
            self.errorLabel.isHidden = true
            authorizeButton.isEnabled = true
        }else {
            self.errorLabel.isHidden = false
            authorizeButton.isEnabled = false
        }
    }
    
    func validateBalanceForPricer(transferBalance: Double) {
        let availableBalance = Double(CurrentUserModel.getInstance.balance)!
        if transferBalance < availableBalance {
            self.errorLabel.isHidden = true
            authorizeButton.isEnabled = true
        }else {
            self.errorLabel.isHidden = false
            authorizeButton.isEnabled = false
        }
    }
    
    //MAKR: - Components
    
    let detailsLabel: UILabel = {
        let view = UILabel()
        view.font = OstFontProvider().get(size: 15).bold()
        view.textColor = UIColor.black.withAlphaComponent(0.4)
        view.text = "Details"
        view.textAlignment = .left
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let balanceLabel: UILabel = {
        let view = UILabel()
        view.font = OstFontProvider().get(size: 12)
        view.textColor = UIColor.color(52, 68, 91)
        view.textAlignment = .right
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let transferContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.color(239, 239, 239, 0.3)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let ruleNameLable: UILabel = {
        let view = UILabel()
        view.font = OstFontProvider().get(size: 12)
        view.textColor = UIColor.color(155, 155, 155)
        view.text = "Rule Name"
        view.textAlignment = .right
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let ruleNameValueLabel: UILabel = {
        let view = UILabel()
        view.font = OstFontProvider().get(size: 12)
        view.textColor = UIColor.color(52, 68, 91)
        view.textAlignment = .right
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let seperatorLine: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.color(239, 239, 239, 0.8)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let sendToLable: UILabel = {
        let view = UILabel()
        view.font = OstFontProvider().get(size: 12)
        view.textColor = UIColor.color(155, 155, 155)
        view.text = "Send to"
        view.textAlignment = .left
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let errorLabel: UILabel = {
        let view = UILabel()
        view.font = OstFontProvider().get(size: 11)
        view.textColor = UIColor.color(222, 53, 11)
        view.textAlignment = .left
        
        let fullString = NSMutableAttributedString(string: "")
        
        // create our NSTextAttachment
        let image1Attachment = NSTextAttachment()
        image1Attachment.image = #imageLiteral(resourceName: "ErrorMessageImage")
        
        
        // wrap the attachment in its own attributed string so we can append it
        let image1String = NSAttributedString(attachment: image1Attachment)
        
        // add the NSTextAttachment wrapper to our full string, then add some more text.
        fullString.append(image1String)
        fullString.append(NSAttributedString(string: " Not enough token balance", attributes: [NSAttributedString.Key.baselineOffset : 3]))
        
        // draw the result in a label
        view.attributedText = fullString
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let authorizeButton: UIButton = {
        let view = OstUIKit.primaryButton()
        view.setTitle("Authorize Transaction", for: .normal)
        
        return view
    }()
    
    let denyButton: UIButton = {
        let view = OstUIKit.linkButton()
        view.setTitle("Deny Request", for: .normal)
        
        return view
    }()
    
    var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.alignment = UIStackView.Alignment.center
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var stackContentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    func getAddressLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = OstFontProvider().get(size: 13)
        view.textColor = UIColor.color(52, 68, 91)
        view.textAlignment = .left
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
    
    func getBalanceLabel() -> UILabel {
        let view = UILabel()
        view.numberOfLines = 0
        view.font = OstFontProvider().get(size: 14).bold()
        view.textColor = UIColor.color(52, 68, 91)
        view.textAlignment = .right
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }
    
    func getTransferView(forAddress address: String, withValue value: String, transferUnit: String? = nil) -> UIView {
        
        let transferUnit: String = transferUnit ?? (CurrentEconomy.getInstance.tokenSymbol ?? "")
        
        let container = UIView()
        
        let addressLabel = getAddressLabel()
        let balanceLabel = getBalanceLabel()
        
        addressLabel.text = address
        balanceLabel.text = "\(value) \(transferUnit)"
        
        container.addSubview(addressLabel)
        container.addSubview(balanceLabel)
        
        addressLabel.topAlignWithParent()
        addressLabel.leftAlignWithParent(multiplier: 1, constant: -2)
        addressLabel.bottomAlign(toItem: container,
                                 multiplier: 1, constant: -10,
                                 relatedBy: .lessThanOrEqual)
        addressLabel.rightAnchor.constraint(equalTo: balanceLabel.leftAnchor, constant: -10).isActive = true
        
        balanceLabel.topAlign(toItem: addressLabel)
        balanceLabel.rightAlignWithParent()
        balanceLabel.bottomAlign(toItem: container,
                                 multiplier: 1, constant: -10,
                                 relatedBy: .lessThanOrEqual)
        balanceLabel.setWidthFromWidth(toItem: container, multiplier: 0.4)
        
        return container
    }
    
    //MAKR: - Add SubViews
    
    override func configure() {
        authorizeButton.addTarget(self, action: #selector(self.authorizeButtonTapped(_ :)), for: .touchUpInside)
        denyButton.addTarget(self, action: #selector(self.denyButtonTapped(_ :)), for: .touchUpInside)
    }
    
    override func getNavBarTitle() -> String {
        return "Confirm Transaction"
    }
    
    override func addSubviews() {
        super.addSubviews()
        
        addSubview(detailsLabel)
        addSubview(balanceLabel)
        addSubview(transferContainer)
        
        transferContainer.addSubview(ruleNameLable)
        transferContainer.addSubview(ruleNameValueLabel)
        transferContainer.addSubview(seperatorLine)
        transferContainer.addSubview(sendToLable)
        transferContainer.addSubview(stackView)
        
        addSubview(errorLabel)
        addSubview(authorizeButton)
        addSubview(denyButton)
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        
        addDetailsLabelLayoutConstraints()
        addBalanceLabelLayoutConstraints()
        addTransferContainerLayoutConstraints()
        
        addRuleNameLableLayoutConstraints()
        addRuleNameValueLabelLayoutConstraints()
        addSeperatorLineLayoutConstraints()
        addSendToLableLayoutConstraints()
        
        addStackViewLayoutConstraints()
        
        transferContainer.bottomAlign(toItem: stackView, constant: 15)
        
        addErrorLabelLayoutConstraints()
        addAuthorizeButtonLayoutConstraints()
        addDenyButtonLayoutConstraints()
        
        let lastView = denyButton
        lastView.bottomAlignWithParent()
    }
    
    func addDetailsLabelLayoutConstraints() {
        detailsLabel.topAlignWithParent(multiplier: 1, constant: 18)
        detailsLabel.leftAlignWithParent(multiplier: 1, constant: 21)
    }
    
    func addBalanceLabelLayoutConstraints() {
        balanceLabel.bottomAlign(toItem: detailsLabel)
        balanceLabel.rightAlignWithParent(multiplier: 1, constant: -21)
        balanceLabel.leftWithRightAlign(toItem: detailsLabel, multiplier: 1, constant: 10, relatedBy: .greaterThanOrEqual)
    }
    
    func addTransferContainerLayoutConstraints() {
        transferContainer.placeBelow(toItem: detailsLabel, constant: 12)
        transferContainer.leftAlign(toItem: detailsLabel)
        transferContainer.rightAlign(toItem: balanceLabel)
    }
    
    func addRuleNameLableLayoutConstraints() {
        ruleNameLable.leftAlignWithParent(multiplier: 1, constant: 12)
        ruleNameLable.topAlignWithParent(multiplier: 1, constant: 16)
    }
    
    func addRuleNameValueLabelLayoutConstraints() {
        ruleNameValueLabel.centerAlignY(toItem: ruleNameLable)
        ruleNameValueLabel.rightAlignWithParent(multiplier: 1, constant: -12)
        ruleNameValueLabel.leftWithRightAlign(toItem: ruleNameLable, multiplier: 1, constant: 10, relatedBy: .greaterThanOrEqual)
    }
    
    func addSeperatorLineLayoutConstraints() {
        seperatorLine.placeBelow(toItem: ruleNameLable, constant: 16)
        seperatorLine.leftAlign(toItem: ruleNameLable)
        seperatorLine.rightAlign(toItem: ruleNameValueLabel)
        seperatorLine.setFixedHeight(constant: 1)
    }
    
    func addSendToLableLayoutConstraints() {
        sendToLable.placeBelow(toItem: seperatorLine, constant: 16)
        sendToLable.leftAlign(toItem: seperatorLine)
    }
    
    func addStackViewLayoutConstraints() {
        stackView.placeBelow(toItem: sendToLable, constant: 4)
        stackView.leftAlign(toItem: seperatorLine)
        stackView.rightAlign(toItem: seperatorLine)
    }
    
    func addErrorLabelLayoutConstraints() {
        errorLabel.placeBelow(toItem: transferContainer, multiplier: 1, constant: 8)
        errorLabel.leftAlign(toItem: transferContainer)
    }
    
    func addAuthorizeButtonLayoutConstraints() {
        authorizeButton.placeBelow(toItem: errorLabel, constant: 16)
        authorizeButton.applyBlockElementConstraints()
    }
    
    func addDenyButtonLayoutConstraints() {
        denyButton.placeBelow(toItem: authorizeButton, constant: 20)
        denyButton.centerXAlignWithParent()
    }
    
    //MAKR: - Actions
    
    @objc func authorizeButtonTapped(_ sender: Any?) {
        (self.delegate as? OstValidateDataDelegate)?.dataVerified()
        self.removeViewController()
    }
    
    @objc func denyButtonTapped(_ sender: Any?) {
        (self.delegate as? OstValidateDataDelegate)?.cancelFlow()
        self.removeViewController()
    }
    
    override func tappedBackButton() {
        (self.delegate as? OstValidateDataDelegate)?.cancelFlow()
        self.removeViewController()
    }
    
}
