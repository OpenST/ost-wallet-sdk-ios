//
//  DAWalletValueTableViewCell.swift
//  DemoApp
//
//  Created by aniket ayachit on 23/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class WalletValueTableViewCell: BaseTableViewCell {
    
    static var cellIdentifier: String {
        return String(describing: WalletValueTableViewCell.self)
    }
    
    var userBalanceDetails: [String: Any]! {
        didSet {
            let balance = CurrentUserModel.getInstance.balance
            setValue(balance)
        }
    }
    
    private func setValue(_ val: String) {
        var balance = val
        if balance.isEmpty {
           balance = "0.00"
        }
        self.tokenSymbolLabel.text = CurrentEconomy.getInstance.tokenSymbol ?? ""
        self.btValueLabel.text =  balance
        if let usdVal = CurrentUserModel.getInstance.toUSD(value: balance)?.toDisplayTxValue() {
            self.usdValueLabel.text = "≈  $ \(usdVal)"
        }else {
            self.usdValueLabel.text = ""
        }
    }
    
    //MAKR: - Components
    var walletBackground: UIView = {
        let container = UIView()
        container.backgroundColor = UIColor.color(154, 204, 215)
        container.layer.cornerRadius = 15.0
        container.translatesAutoresizingMaskIntoConstraints = false
        
        return container
    }()

    var valueContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        container.clipsToBounds = true
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        return container
    }()
    
    var yourBalLabel: UILabel = {
        let view = UILabel()
        view.font = OstFontProvider().get(size: 13).bold()
        view.textColor = UIColor.color(52, 68, 91)
        view.textAlignment = .left
        view.text = "Your Balance"
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var tokenSymbolLabel: UILabel = {
        let label = UILabel()
        label.font = OstFontProvider().get(size: 32).bold()
        label.textAlignment = .center
        label.textColor = UIColor.color(52, 68, 91)
        label.sizeToFit()
       
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    var btValueContainer: UIView = {
        let container = UIView()
        container.backgroundColor = .clear
        container.clipsToBounds = true
        container.layer.cornerRadius = 5
        container.backgroundColor = .clear
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        return container
    }()
    
    var btValueLabel: UILabel = {
        let btLabel = UILabel()
        btLabel.font = OstFontProvider().get(size: 32).bold()
        btLabel.textAlignment = .left
        btLabel.minimumScaleFactor = 0.5
        btLabel.textColor = UIColor.color(52, 68, 91)
        btLabel.clipsToBounds = true
        
        btLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return btLabel
    }()
    
    var usdValueLabel: UILabel = {
        let usdLabel = UILabel()
        usdLabel.font = OstFontProvider().get(size: 16)
        usdLabel.textColor = UIColor.color(52, 68, 91)
        usdLabel.textAlignment = .left
        
        usdLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return usdLabel
    }()
    
    //MARK: - Create Views
    override func createViews() {
        addSubview(walletBackground)
        walletBackground.addSubview(valueContainer)
        
        valueContainer.addSubview(yourBalLabel)
        valueContainer.addSubview(btValueContainer)
        btValueContainer.addSubview(btValueLabel)
        valueContainer.addSubview(usdValueLabel)
        valueContainer.addSubview(tokenSymbolLabel)
        
        self.selectionStyle = .none
    }
    
    //MARK: - Apply Constraints
    
    override func applyConstraints() {
        applyWalletContainerConstraints()
        
        applyValueContainerConstraints()
        applyYourBalLabelConstraints()
        applyBtValueContainerConstraints()
        applyBtValueLabelConstraints()
        applyTokenSymbolLabelConstraints()
        applyUsdValueLabelConstraints()
    }
    
    
    func applyWalletContainerConstraints() {
        guard let parent = self.walletBackground.superview else {return}
        self.walletBackground.topAnchor.constraint(equalTo: parent.topAnchor, constant: 22.0).isActive = true
        self.walletBackground.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 22.0).isActive = true
        self.walletBackground.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -22.0).isActive = true
        self.walletBackground.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -22.0).isActive = true
    }

    func applyValueContainerConstraints() {
        guard let parent = self.valueContainer.superview else {return}
        valueContainer.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 16.0).isActive = true
        valueContainer.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -16.0).isActive = true
        valueContainer.topAnchor.constraint(equalTo: self.yourBalLabel.topAnchor, constant: 0.0).isActive = true
        valueContainer.bottomAnchor.constraint(equalTo: self.usdValueLabel.bottomAnchor, constant: 0.0).isActive = true
        
        valueContainer.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
    
    func applyTokenSymbolLabelConstraints() {
        guard let parent = self.tokenSymbolLabel.superview else {return}
        tokenSymbolLabel.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        tokenSymbolLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        tokenSymbolLabel.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
    }
    
    func applyBtValueContainerConstraints() {
        guard let parent = self.btValueContainer.superview else {return}
        btValueContainer.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
        btValueContainer.leftAnchor.constraint(equalTo: tokenSymbolLabel.rightAnchor, constant: 18).isActive = true
        btValueContainer.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        btValueContainer.heightAnchor.constraint(equalToConstant: 60).isActive = true
    }
    
    func applyYourBalLabelConstraints() {
        yourBalLabel.leftAnchor.constraint(equalTo: btValueContainer.leftAnchor).isActive = true
        yourBalLabel.rightAnchor.constraint(equalTo: btValueContainer.rightAnchor).isActive = true
        yourBalLabel.bottomAnchor.constraint(equalTo: btValueContainer.topAnchor, constant: -4).isActive = true
    }
    
    func applyBtValueLabelConstraints() {
        guard let parent = self.btValueLabel.superview else {return}
        btValueLabel.leftAnchor.constraint(equalTo: parent.leftAnchor).isActive = true
        btValueLabel.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        btValueLabel.rightAnchor.constraint(equalTo: parent.rightAnchor).isActive = true
    }

    func applyUsdValueLabelConstraints() {
        usdValueLabel.leftAnchor.constraint(equalTo: btValueContainer.leftAnchor).isActive = true
        usdValueLabel.rightAnchor.constraint(equalTo: btValueContainer.rightAnchor).isActive = true
        usdValueLabel.topAnchor.constraint(equalTo: btValueContainer.bottomAnchor, constant: 4).isActive = true
    }
}
