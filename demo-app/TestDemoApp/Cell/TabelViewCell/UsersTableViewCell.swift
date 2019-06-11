//
//  UsersTableViewCell.swift
//  DemoApp
//
//  Created by aniket ayachit on 20/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class UsersTableViewCell: BaseTableViewCell {
    
    static var usersCellIdentifier: String {
        return String(describing: UsersTableViewCell.self)
    }
    
    //MARK: - Variables
    var userData: [String: Any]! {
        didSet {
            setName()
        }
    }
    func setName() {
        let name: String = (userData["username"] as? String) ?? ""
        self.titleLabel?.text = name
        
        let fistLetter = name.character(at: 0)
        self.initialLetter?.text = (fistLetter == nil) ? "" : "\(fistLetter!)".uppercased()
        
        let tokenHolderAddress: String? = userData["token_holder_address"] as? String
        self.sendButton?.isEnabled = tokenHolderAddress == nil ? false : true
        
        self.sendButton?.isHidden = false
        if let appUserId = ConversionHelper.toString(userData["app_user_id"]) {
            if appUserId.caseInsensitiveCompare(CurrentUserModel.getInstance.appUserId ?? "")  == .orderedSame {
                 self.sendButton?.isHidden = true
            }
        }
        
    }
    
    var userBalance: [String: Any]! {
        didSet {
            setBalance()
        }
    }
    
    func setBalance() {
        if let balance = userBalance["available_balance"] {
            let amountVal = ConversionHelper.toString(balance)!.toRedableFormat()
            self.balanceLabel?.textColor = UIColor.black.withAlphaComponent(0.48)
            self.balanceLabel?.text = "Balance: \(amountVal.toDisplayTxValue()) \(CurrentEconomy.getInstance.tokenSymbol ?? "")"
        }else {
            self.balanceLabel?.textColor = UIColor.color(255, 94, 84)
            self.balanceLabel?.text = "Initializing user..."
        }
    }
    
    var sendButtonAction: (([String: Any]?) -> Void)? = nil
    
    //MARK: - Components
    var circularView: UIView?
    var initialLetter: UILabel?
    var detailsContainerView: UIView?
    var titleLabel: UILabel?
    var balanceLabel: UILabel?
    var sendButton: UIButton?
    var seperatorLine: UIView?
    
    
    //MARK: - Create Views
    override func createViews() {
        super.createViews()
        createCircularView()
        createSeperatorLine()
        createNameLabel()
        createBalanaceLabel()
        createDetailsContainerView()
        createDetailsContainerView()
        createSendButton()
        
        self.selectionStyle = .none
    }
    
    func createCircularView() {
        let circularView = UIView()
        circularView.backgroundColor = UIColor.color(244, 244, 244)
        circularView.layer.cornerRadius = 25
        self.circularView = circularView

        createInternalView()
        self.addSubview(circularView)
    }
    
    func createInternalView(){
        let letter = UILabel()
        letter.textColor = UIColor.color(136, 136, 136)
        letter.numberOfLines = 1
        letter.font = OstTheme.fontProvider.get(size: 20).bold()
    
        self.initialLetter = letter
        circularView!.addSubview(letter)
    }
    
    func createSeperatorLine() {
        let seperatorLine = UIView()
        seperatorLine.backgroundColor = UIColor.color(244, 244, 244)
        
        self.seperatorLine = seperatorLine
        self.addSubview(seperatorLine)
    }
    
    func createNameLabel() {
        let nameLabel = UILabel()
        nameLabel.numberOfLines = 0
        nameLabel.textAlignment = .left
        nameLabel.textColor = UIColor.color(52, 68, 91)
        nameLabel.font = OstTheme.fontProvider.get(size: 16)
        self.titleLabel = nameLabel
    }
    
    func createBalanaceLabel() {
        let loBalanaceLabel = UILabel()
        loBalanaceLabel.numberOfLines = 0
        loBalanaceLabel.textAlignment = .left
        loBalanaceLabel.textColor = UIColor.darkGray
        loBalanaceLabel.font = OstTheme.fontProvider.get(size: 13)
        self.balanceLabel = loBalanaceLabel
    }
    
    func createDetailsContainerView() {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLabel!)
        view.addSubview(balanceLabel!)
        
        self.detailsContainerView = view
        self.addSubview(view)
    }
    
    func createSendButton() {
        let button = OstUIKit.primaryButton()
        button.setTitle("SEND", for: .normal)
        weak var weakSelf = self
        button.addTarget(weakSelf, action: #selector(weakSelf!.sendButtonTapped(_:)), for: .touchUpInside)
        
        self.sendButton = button
        self.addSubview(button)
    }
    
    //MARK: - Apply Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        applyCircularViewConstraints()
        applyInitialLetterConstraints()
        applyTitleLabelConstraitns()
        applyBalanceLabelConstraitns()
        applyDetailsViewConstraints()
        applySendButtonConstraints()
        applySeperatorLineConstraints()
    }
    
    func applyCircularViewConstraints() {
        guard let parent = self.circularView?.superview else {return}
        self.circularView?.translatesAutoresizingMaskIntoConstraints = false
        self.circularView?.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 12).isActive = true
        self.circularView?.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.circularView?.heightAnchor.constraint(equalTo: (self.circularView?.widthAnchor)!).isActive = true
        self.circularView?.topAnchor.constraint(equalTo: parent.topAnchor, constant: 12).isActive = true
    }
    
    func applyInitialLetterConstraints() {
        self.initialLetter?.translatesAutoresizingMaskIntoConstraints = false
        self.initialLetter?.centerYAnchor.constraint(equalTo: self.circularView!.centerYAnchor).isActive = true
        self.initialLetter?.centerXAnchor.constraint(equalTo: self.circularView!.centerXAnchor).isActive = true
    }
    
    func applyTitleLabelConstraitns() {
        guard let parent = self.titleLabel?.superview else {return}
        self.titleLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel?.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.titleLabel?.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        self.titleLabel?.rightAnchor.constraint(lessThanOrEqualTo: parent.rightAnchor).isActive = true
    }
    
    func applyBalanceLabelConstraitns() {
        guard let parent = self.titleLabel?.superview else {return}
        self.balanceLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.balanceLabel?.topAnchor.constraint(equalTo: self.titleLabel!.bottomAnchor, constant: 0).isActive = true
        self.balanceLabel?.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        self.balanceLabel?.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        self.balanceLabel?.bottomAnchor.constraint(equalTo: parent.bottomAnchor).isActive = true
    }
    
    func applyDetailsViewConstraints() {
        self.detailsContainerView?.translatesAutoresizingMaskIntoConstraints = false
        self.detailsContainerView?.leftAnchor.constraint(equalTo: self.circularView!.rightAnchor, constant: 8.0).isActive = true
        self.detailsContainerView?.rightAnchor.constraint(equalTo: self.sendButton!.leftAnchor, constant: -8.0).isActive = true
        self.detailsContainerView?.topAnchor.constraint(equalTo: circularView!.topAnchor, constant:4.0).isActive = true
        self.detailsContainerView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:-12.0).isActive = true
    }
    
    func applySendButtonConstraints() {
        self.sendButton?.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -18.0).isActive = true
        self.sendButton?.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0.0).isActive = true
        self.sendButton?.widthAnchor.constraint(lessThanOrEqualToConstant: 80).isActive = true
        self.sendButton?.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    }
    
    func applySeperatorLineConstraints() {
        self.seperatorLine?.translatesAutoresizingMaskIntoConstraints = false
        self.seperatorLine?.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        self.seperatorLine?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive =  true
        self.seperatorLine?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12.0).isActive = true
        self.seperatorLine?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0.0).isActive = true
    }
    
    @objc func sendButtonTapped(_ sender: Any?) {
        sendButtonAction?(self.userData)
    }
}
