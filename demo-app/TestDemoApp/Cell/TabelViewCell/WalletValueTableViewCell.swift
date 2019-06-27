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
        
        self.btValueLabel.text =  "\(balance) \(CurrentEconomy.getInstance.tokenSymbol ?? "")"
        if let usdVal = CurrentUserModel.getInstance.toUSD(value: balance)?.toDisplayTxValue() {
            self.usdValueLabel.text = "$\(usdVal)"
        }else {
            self.usdValueLabel.text = ""
        }
    }
    
    //MAKR: - Components
    var walletBackground: UIView = {
        let container = UIView()
        container.layer.cornerRadius = 15.0
        container.clipsToBounds = true
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "WalletBackgroundImage")
        
        container.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAlignWithParent()
        imageView.bottomAlignWithParent()
        imageView.leftAlignWithParent()
        imageView.rightAlignWithParent()
        
        return container
    }()

    var btValueLabel: UILabel = {
        let btLabel = UILabel()
        btLabel.font = OstTheme.fontProvider.getBlack(size: 32)
        btLabel.textAlignment = .center
        btLabel.minimumScaleFactor = 0.5
        btLabel.textColor = UIColor.color(52, 68, 91)
        btLabel.clipsToBounds = true
        
        btLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return btLabel
    }()
    
    var usdValueLabel: UILabel = {
        let usdLabel = UILabel()
        usdLabel.font = OstTheme.fontProvider.get(size: 16).bold()
        usdLabel.textColor = UIColor.color(52, 68, 91)
        usdLabel.textAlignment = .left
        
        usdLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return usdLabel
    }()
    
    //MARK: - Create Views
    override func createViews() {
        addSubview(walletBackground)
        walletBackground.addSubview(btValueLabel)
        walletBackground.addSubview(usdValueLabel)
        
        self.selectionStyle = .none
    }
    
    //MARK: - Apply Constraints
    
    override func applyConstraints() {
        applyWalletContainerConstraints()
        applyBtValueLabelConstraints()
        applyUsdValueLabelConstraints()
    }
    
    
    func applyWalletContainerConstraints() {
        guard let parent = self.walletBackground.superview else {return}
        self.walletBackground.topAnchor.constraint(equalTo: parent.topAnchor, constant: 22.0).isActive = true
        self.walletBackground.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 22.0).isActive = true
        self.walletBackground.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -22.0).isActive = true
        self.walletBackground.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -22.0).isActive = true
    }

    func applyBtValueLabelConstraints() {
        btValueLabel.centerYAlignWithParent(multiplier: 1, constant: -10)
        btValueLabel.centerXAlignWithParent()
    }

    func applyUsdValueLabelConstraints() {
        usdValueLabel.topAnchor.constraint(equalTo: btValueLabel.bottomAnchor, constant: 4).isActive = true
        usdValueLabel.centerXAlignWithParent()
    }
}
