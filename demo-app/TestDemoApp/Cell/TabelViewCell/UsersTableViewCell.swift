//
//  UsersTableViewCell.swift
//  DemoApp
//
//  Created by aniket ayachit on 20/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

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
    }
    
    var userBalance: [String: Any]! {
        didSet {
            setBalance()
        }
    }
    
    func setBalance() {
        if let balance: String = userBalance["available_balance"] as? String {
            self.balanceLabel?.textColor = UIColor.black.withAlphaComponent(0.48)
            self.balanceLabel?.text = "Balance: \(balance)"
        }else {
            self.balanceLabel?.textColor = UIColor.color(255, 94, 84)
            self.balanceLabel?.text = "Wallet Setup Incomplete"
        }
    }
    
    var sendButtonAction: (([String: Any]?) -> Void)? = nil
    
    //MARK: - Components
    var circularView: UIView?
    var initialLetter: UILabel?
    var stackView: UIStackView?
    var titleLabel: UILabel?
    var balanceLabel: UILabel?
    var sendButton: UIButton?
    var seperatorLine: UIView?
    
    
    //MARK: - Create Views
    override func createViews() {
        super.createViews()
        createcirCularView()
        createSeperatorLine()
        createNameLabel()
        createBalanaceLabel()
        createStackView()
        createSendButton()
    }
    
    func createcirCularView() {
        let circularView = UIView()
        circularView.backgroundColor = UIColor.color(244, 244, 244)
        circularView.layer.cornerRadius = 25
        
        let letter = UILabel()
        letter.textColor = UIColor.color(136, 136, 136)
        letter.numberOfLines = 1
        letter.font = OstFontProvider().get(size: 20).bold()
        
        self.initialLetter = letter
        circularView.addSubview(letter)
        
        self.circularView = circularView
        self.addSubview(circularView)
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
        nameLabel.textColor = UIColor.black
        nameLabel.font = OstFontProvider().get(size: 17)
        self.titleLabel = nameLabel
    }
    
    func createBalanaceLabel() {
        let loBalanaceLabel = UILabel()
        loBalanaceLabel.numberOfLines = 0
        loBalanaceLabel.textAlignment = .left
        loBalanaceLabel.textColor = UIColor.darkGray
        loBalanaceLabel.font = OstFontProvider().get(size: 15)
        self.balanceLabel = loBalanaceLabel
    }
    
    func createStackView() {
        let loStackView = UIStackView(arrangedSubviews: [self.titleLabel!, self.balanceLabel!])
        loStackView.axis = .vertical
        loStackView.distribution = .fillEqually
        loStackView.alignment = .lastBaseline
        
        self.stackView = loStackView
        self.addSubview(loStackView)
    }
    
    func createSendButton() {
        let loSendButton = UIButton()
        loSendButton.layer.cornerRadius = 15.0
        loSendButton.clipsToBounds = true
        loSendButton.setTitle("SEND", for: .normal)
        
        loSendButton.setTitleColor(UIColor.color(0,122,255), for: .normal)
        loSendButton.setTitleColor(UIColor.color(0,122,255, 0.3), for: .disabled)
        
        loSendButton.setBackgroundImage(UIImage.withColor(239,239,244), for: .normal)
        loSendButton.setBackgroundImage(UIImage.withColor(239,239,244, 0.3), for: .disabled)
        
        loSendButton.titleLabel?.font = OstFontProvider().get(size: 15)
        weak var weakSelf = self
        loSendButton.addTarget(weakSelf, action: #selector(weakSelf!.sendButtonTapped(_:)), for: .touchUpInside)
        
        self.sendButton = loSendButton
        self.addSubview(loSendButton)
    }
    
    //MARK: - Apply Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        applyCircularViewConstraints()
        applyInitialLetterConstraints()
        applyStackViewConstraints()
        applySendButtonConstraints()
        applySeperatorLineConstraints()
    }
    
    func applyCircularViewConstraints() {
        self.circularView?.translatesAutoresizingMaskIntoConstraints = false
        self.circularView?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        self.circularView?.widthAnchor.constraint(equalToConstant: 50).isActive = true
        self.circularView?.heightAnchor.constraint(equalTo: (self.circularView?.widthAnchor)!).isActive = true
        self.circularView?.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    func applyInitialLetterConstraints() {
        self.initialLetter?.translatesAutoresizingMaskIntoConstraints = false
        self.initialLetter?.centerYAnchor.constraint(equalTo: self.circularView!.centerYAnchor).isActive = true
        self.initialLetter?.centerXAnchor.constraint(equalTo: self.circularView!.centerXAnchor).isActive = true
    }
    
    func applyStackViewConstraints() {
        self.stackView?.translatesAutoresizingMaskIntoConstraints = false
        self.stackView?.leftAnchor.constraint(equalTo: self.circularView!.rightAnchor, constant: 8.0).isActive = true
        self.stackView?.rightAnchor.constraint(equalTo: self.sendButton!.leftAnchor, constant: -8.0).isActive = true
        self.stackView?.topAnchor.constraint(equalTo: self.topAnchor, constant:12.0).isActive = true
        self.stackView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:-12.0).isActive = true
    }
    
    func applySendButtonConstraints() {
        self.sendButton?.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -18.0).isActive = true
        self.sendButton?.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0.0).isActive = true
        self.sendButton?.widthAnchor.constraint(equalToConstant: 85.0).isActive = true
        self.sendButton?.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    }
    
    func applySeperatorLineConstraints() {
        self.seperatorLine?.translatesAutoresizingMaskIntoConstraints = false
        self.seperatorLine?.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        self.seperatorLine?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0).isActive =  true
        self.seperatorLine?.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12.0).isActive = true
        self.seperatorLine?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -12.0).isActive = true
    }
    
    @objc func sendButtonTapped(_ sender: Any?) {
        sendButtonAction?(self.userData)
    }
}
