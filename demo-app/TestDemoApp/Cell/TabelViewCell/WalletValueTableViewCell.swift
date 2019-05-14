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
    
    func setValue(_ val: String) {
        if let doubleVal:Double =  Double(val) {
             self.btValueLabel?.text = "\(CurrentEconomy.getInstance.tokenSymbol ?? "") \(String(format: "%g",doubleVal))"
        }else {
            self.btValueLabel?.text = "\(CurrentEconomy.getInstance.tokenSymbol ?? "") 0"
        }
    }
    
    //MAKR: - Components
    var walletBackground: UIView?
    var valueContainer: UIView?
    var btValueLabel: UILabel?
    var usdValueLabel: UILabel?
    
    //MARK: - Variables
    let maxDuration = TimeInterval(exactly: 1)!
    var displayLink: CADisplayLink?
    
    override func setVariables() {
        displayLink = CADisplayLink(target: self, selector: #selector(counter))
    }
    
    
    //MARK: - Create Views
    override func createViews() {
        createWalletValueContainer()
        createValueContainer()
        crateBtValueLabel()
        crateUSDValueLabel()
    }
    
    func createWalletValueContainer() {
        let container = UIView()
        container.backgroundColor = UIColor.color(154, 204, 215)
        container.layer.cornerRadius = 15.0
        
        self.walletBackground = container
        self.addSubview(container)
    }
    
    func createValueContainer() {
        let container = UIView()
        container.backgroundColor = .clear
        container.clipsToBounds = true
        
        self.valueContainer = container
        self.addSubview(container)
    }
    
    func crateBtValueLabel() {
        let btLabel = UILabel()
        btLabel.font = OstFontProvider().get(size: 32).bold()
        btLabel.textAlignment = .center
        btLabel.minimumScaleFactor = 0.5
        btLabel.textColor = UIColor.white
        self.btValueLabel = btLabel
        self.valueContainer?.addSubview(btLabel)
    }
    
    func crateUSDValueLabel() {
        let usdLabel = UILabel()
        usdLabel.font = OstFontProvider().get(size: 16)
        usdLabel.textColor = UIColor.white
        usdLabel.textAlignment = .center
        self.usdValueLabel = usdLabel
        self.valueContainer?.addSubview(usdLabel)
    }
    
    //MARK: - Apply Constraints
    
    override func applyConstraints() {
        applyWalletContainerConstraints()
        applyValueContainerConstraints()
        applyBtValueLabelConstraint()
        applyUSDValueLabelConstraint()
    }
    
    func applyWalletContainerConstraints() {
        guard let parent = self.walletBackground?.superview else {return}
        self.walletBackground?.translatesAutoresizingMaskIntoConstraints = false
        self.walletBackground?.topAnchor.constraint(equalTo: parent.topAnchor, constant: 22.0).isActive = true
        self.walletBackground?.leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 22.0).isActive = true
        self.walletBackground?.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -22.0).isActive = true
        self.walletBackground?.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -22.0).isActive = true
    }
    
    func applyValueContainerConstraints() {
        guard let parent = self.valueContainer?.superview else {return}
        self.valueContainer?.translatesAutoresizingMaskIntoConstraints = false
        self.valueContainer?.leftAnchor.constraint(equalTo: self.walletBackground!.leftAnchor, constant: 12.0).isActive = true
        self.valueContainer?.rightAnchor.constraint(equalTo: self.walletBackground!.rightAnchor, constant: -12.0).isActive = true
        self.valueContainer?.centerYAnchor.constraint(equalTo: parent.centerYAnchor).isActive = true
        self.valueContainer?.centerXAnchor.constraint(equalTo: parent.centerXAnchor).isActive = true
        self.valueContainer?.bottomAnchor.constraint(equalTo: self.usdValueLabel!.bottomAnchor).isActive = true
    }
    
    func applyBtValueLabelConstraint() {
        guard let parent = self.btValueLabel?.superview else {return}
        self.btValueLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.btValueLabel?.topAnchor.constraint(equalTo: parent.topAnchor).isActive = true
        self.btValueLabel?.leftAnchor.constraint(equalTo: self.valueContainer!.leftAnchor).isActive = true
        self.btValueLabel?.rightAnchor.constraint(equalTo: self.valueContainer!.rightAnchor).isActive = true
    }
    
    func applyUSDValueLabelConstraint() {
        self.usdValueLabel?.translatesAutoresizingMaskIntoConstraints = false
        self.usdValueLabel?.topAnchor.constraint(equalTo: self.btValueLabel!.bottomAnchor, constant: 10.0).isActive = true
        self.usdValueLabel?.leftAnchor.constraint(equalTo: self.valueContainer!.leftAnchor).isActive = true
        self.usdValueLabel?.rightAnchor.constraint(equalTo: self.valueContainer!.rightAnchor).isActive = true
    }
    
    override func endDisplay() {
        animate()
    }
    
    //MARK: - Animation
    var startTime: Date?
    var startValue = Double(exactly: 0)!
    var endValue = Double(exactly: 100)!
    var diff: Double?
    
    func animate() {
        let availabelBalance = CurrentUserModel.getInstance.balance
        if !availabelBalance.isEmpty {
            endValue = Double(availabelBalance)!
            diff = endValue - startValue
            startTime = Date()
            displayLink?.add(to: .current, forMode: .default)
        }
    }
    
    @objc func counter() {
        let elapsedTime = Date().timeIntervalSince(startTime!)
        if elapsedTime > maxDuration {
            displayLink?.invalidate()
            displayLink = nil
            setValue("\(endValue)")
            return
        }
        let percent = elapsedTime/maxDuration
        let value = startValue + (percent * diff!)
        setValue("\(value)")
    }
}
