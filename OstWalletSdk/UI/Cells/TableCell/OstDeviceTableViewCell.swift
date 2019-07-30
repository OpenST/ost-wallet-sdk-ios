//
//  UsersTableViewCell.swift
//  DemoApp
//
//  Created by aniket ayachit on 20/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class OstDeviceTableViewCell: OstBaseTableViewCell {
    
    static var deviceCellIdentifier: String {
        return String(describing: OstDeviceTableViewCell.self)
    }
    
    private var deviceDetails: [String: Any]? {
        didSet {
            self.deviceAddressLabel.text = deviceDetails?["address"] as? String ?? ""
        }
    }
    
    func setDeviceDetails(_ deviceDetails: [String: Any]?, forIndex index: Int) {
        self.deviceDetails = deviceDetails
        self.deviceNameLabel.text = "Device \(index)"
    }
    
    var onActionPressed: (([String: Any]?) -> Void)? = nil
    
    //MARK: - Components
    let deviceCellBackgroundView: UIView = {
       
        let view = UIView()
        
        view.backgroundColor = UIColor.color(248, 248, 248)
        view.layer.cornerRadius = 5
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let phoneImageView: UIImageView = {
        let view = UIImageView()
        
        view.contentMode = ContentMode.scaleAspectFit
    
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let deviceDetailsContainer: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let deviceNameLabel: OstC1Label = {
        let view = OstC1Label(text: "deviceNameLabel")
        view.textAlignment = NSTextAlignment.left
        return view
    }()
    
    let deviceAddressTextLabel: OstC2Label = {
        let view = OstC2Label(text: "Device Address")
        view.textAlignment = NSTextAlignment.left
        return view
    }()
    
    let deviceAddressLabel: OstC1Label = {
        let view = OstC1Label(text: "deviceAddressLabel")
        view.textAlignment = NSTextAlignment.left
        return view
    }()
    
    let actionButton: OstB1Button = {
        let view = OstB1Button(title: "")
        
        return view
    }()
    
    
    //MARK: - Create views
    override func createViews() {
        super.createViews()
        
        self.addToContentView(deviceCellBackgroundView)
        
        deviceCellBackgroundView.addSubview(phoneImageView)
        deviceCellBackgroundView.addSubview(deviceDetailsContainer)
        
        deviceDetailsContainer.addSubview(deviceNameLabel)
        deviceDetailsContainer.addSubview(deviceAddressTextLabel)
        deviceDetailsContainer.addSubview(deviceAddressLabel)
        deviceDetailsContainer.addSubview(actionButton)
    }
    
    override func setValuesForComponents() {
        super.setValuesForComponents()
        
        self.phoneImageView.image = UIImage(named: "ost_device_placeholder",
                                       in: Bundle(for: type(of: self)),
                                       compatibleWith: nil)!
        
        self.actionButton.setTitle("Start Recovery", for: .normal)
        self.actionButton.addTarget(self, action: #selector(actionButtonTapped(_ :)), for: .touchUpInside)
    }
    
    //MARK: - Apply Constraints
    override func applyConstraints() {
        deviceCellBackgroundViewApplyConstraints()
        phoneImageViewApplyConstraints()
        
        deviceDetailsContainerApplyConstrainsts()
        deviceNameLabelApplyConstraints()
        deviceAddressTextLabelApplyConstraints()
        deviceAddressLabelApplyConstraitns()
        actionButtonApplyConstraitns()
    }
    
    func deviceCellBackgroundViewApplyConstraints() {
        deviceCellBackgroundView.topAlignWithParent(multiplier: 1, constant: 0)
        deviceCellBackgroundView.leftAlignWithParent(multiplier: 1, constant: 20)
        deviceCellBackgroundView.rightAlignWithParent(multiplier: 1, constant: -20)
        deviceCellBackgroundView.bottomAlignWithParent(multiplier: 1, constant: -20)
    }
    
    func phoneImageViewApplyConstraints() {
        phoneImageView.leftAlignWithParent(multiplier: 1, constant: 24)
        phoneImageView.centerYAlignWithParent()
        phoneImageView.setW375Width(width: 36)
        phoneImageView.setH667Height(height: 58)
    }
    
    func deviceDetailsContainerApplyConstrainsts() {
        deviceDetailsContainer.topAlignWithParent(multiplier: 1, constant: 18)
        deviceDetailsContainer.leftWithRightAlign(toItem: phoneImageView, constant: 24)
        deviceDetailsContainer.rightAlignWithParent()
        deviceDetailsContainer.bottomAlignWithParent(multiplier: 1, constant: -18)
    }
    
    func deviceNameLabelApplyConstraints() {
        deviceNameLabel.topAlignWithParent()
        deviceNameLabel.leftAlignWithParent()
        deviceNameLabel.rightAlignWithParent(multiplier: 1, constant: -10)
    }
    
    func deviceAddressTextLabelApplyConstraints() {
        deviceAddressTextLabel.placeBelow(toItem: deviceNameLabel, multiplier: 1, constant: 10)
        deviceAddressTextLabel.leftAlignWithParent()
        deviceAddressTextLabel.rightAlignWithParent(multiplier: 1, constant: -10)
    }
    
    func deviceAddressLabelApplyConstraitns() {
        deviceAddressLabel.placeBelow(toItem: deviceAddressTextLabel, multiplier: 1, constant: 4)
        deviceAddressLabel.leftAlignWithParent()
        deviceAddressLabel.rightAlignWithParent(multiplier: 1, constant: -10)
    }
    
    func actionButtonApplyConstraitns() {
        actionButton.placeBelow(toItem: deviceAddressLabel, multiplier: 1, constant: 15)
        actionButton.leftAlignWithParent()
        actionButton.bottomAlignWithParent()
    }
    
    //MARK: - Action
    @objc func actionButtonTapped(_ sender: Any) {
        self.onActionPressed?(self.deviceDetails)
    }
    
}
