/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

class EmptyTransactionTableViewCell: BaseTableViewCell {
    
    static var emptyTransactionTCellIdentifier: String {
        return "EmptyTransactionTableViewCell"
    }
    
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.color(250, 250, 250)
        return view
    }()
    
    let titleLabel: UILabel = {
        var label = OstUIKit.h1()
        label.textColor = UIColor.color(52, 68, 91)
        
        return label
    }()
    
    let leadLabel: UILabel = {
        let label = OstUIKit.leadLabel()
        label.textAlignment = .center
        label.textColor = UIColor.color(89, 122, 132)
        return label
    }()
    
    override func createViews() {
        super.createViews()
        
        self.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(leadLabel)
        
        self.selectionStyle = .none
    }
    
    override func applyConstraints() {
        applyContainerViewConstraints()
        applyTitleLabelConstraints()
        applyLeadLabelConstraints()
        
        leadLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -27).isActive = true
    }
    
    func applyContainerViewConstraints() {
        guard let parent = containerView.superview else {return}
        containerView.topAnchor.constraint(equalTo: parent.topAnchor, constant: 8).isActive = true
        containerView.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 21).isActive = true
        containerView.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -21).isActive = true
    }
    
    func applyTitleLabelConstraints() {
        guard let parent = titleLabel.superview else {return}
        titleLabel.topAnchor.constraint(equalTo: parent.topAnchor, constant: 27).isActive = true
        titleLabel.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 17).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -17).isActive = true
    }
    
    func applyLeadLabelConstraints() {
        guard let parent = leadLabel.superview else {return}
        leadLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12).isActive = true
        leadLabel.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 17).isActive = true
        leadLabel.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -17).isActive = true
    }
    
    func showWalletSettingUpView() {
        self.titleLabel.text = "Your wallet is being setup"
        let currentEconomy = CurrentEconomy.getInstance
        self.leadLabel.text = "The wallet setup process takes about 30 seconds. You’ll also receive an airdrop of 10 \(currentEconomy.tokenSymbol ?? "tokens")  to test with."
        
    }
    
    func showNoTransactionView() {
        self.titleLabel.text = "No Transactions Completed!"
        self.leadLabel.text = "Looks like you have not made any transactions, send some tokens to other users"
    }
}
