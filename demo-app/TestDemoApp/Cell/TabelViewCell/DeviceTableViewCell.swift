/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

class DeviceTableViewCell: UsersTableViewCell {
    
    static var deviceCellIdentifier: String {
        return "DeviceTableViewCell"
    }
    
    func setDeviceDetails(details: [String: Any], withIndex indexVal: Int) {
        self.deviceDetails = details
        self.titleLabel?.text = "Device \(indexVal)"
    }
    
    var deviceDetails: [String: Any]! {
        didSet {
            self.balanceLabel?.text = deviceDetails["address"] as? String ?? ""
            let titleText = getButtonTitleForDeviceState()
            if titleText.isEmpty {
                sendButtonHeightConstraint?.constant = 0.0
                sendButton?.isHidden = true
            }else {
                sendButtonHeightConstraint?.constant = 30.0
                sendButton?.isHidden = false
                sendButton?.setTitle(titleText, for: .normal)

                let currentUserDevice = CurrentUserModel.getInstance.userDevice!
                
                if address.caseInsensitiveCompare(currentUserDevice.address!) == .orderedSame {
                     sendButton?.isEnabled = false
                }
                else if (!currentUserDevice.isStatusRegistered
                        && status.caseInsensitiveCompare(ManageDeviceViewController.DeviceStatus.registered.rawValue) == .orderedSame) {
                    
                    sendButton?.isEnabled = false
                }
                else {
                    sendButton?.isEnabled = true
                }
            }
        }
    }
    
    func getButtonTitleForDeviceState() -> String {
        let currentUserDevice = CurrentUserModel.getInstance.userDevice!
        
        if status.caseInsensitiveCompare(currentUserDevice.status ?? "") == .orderedSame {
            return ""
        }
        
        switch (deviceDetails["status"] as! String).lowercased() {
        case ManageDeviceViewController.DeviceStatus.authorized.rawValue:
            if currentUserDevice.isStatusAuthorized {
                return "Revoke"
            }else if currentUserDevice.isStatusRegistered {
                return "Initiate Recovery"
            }
            
        case ManageDeviceViewController.DeviceStatus.recovering.rawValue:
            return "Abort Recovery"
            
        case ManageDeviceViewController.DeviceStatus.registered.rawValue:
            return "Initiate Recovery"
            
        case ManageDeviceViewController.DeviceStatus.revoking.rawValue:
            return "Abort Recovery"
            
        case ManageDeviceViewController.DeviceStatus.revoked.rawValue:
            return ""
            
        default:
            return ""
        }
        return ""
    }
    
    //MARK: - Variables
    var status: String {
        return  deviceDetails["status"] as? String ?? ""
    }
    
    var address: String {
        return deviceDetails["address"] as? String ?? ""
    }
    
    var sendButtonHeightConstraint: NSLayoutConstraint? = nil

    
    //MARK: - Apply Constraints
    override func applyDetailsViewConstraints() {
        self.detailsContainerView?.translatesAutoresizingMaskIntoConstraints = false
        self.detailsContainerView?.leftAnchor.constraint(equalTo: self.circularView!.rightAnchor, constant: 8.0).isActive = true
        self.detailsContainerView?.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8.0).isActive = true
        self.detailsContainerView?.topAnchor.constraint(equalTo: circularView!.topAnchor, constant:4.0).isActive = true
    }
    
    override func applySendButtonConstraints() {
        self.sendButton?.translatesAutoresizingMaskIntoConstraints = false
        self.sendButton?.leftAnchor.constraint(equalTo: self.detailsContainerView!.leftAnchor).isActive = true
        self.sendButton?.topAnchor.constraint(equalTo: self.detailsContainerView!.bottomAnchor, constant:12.0).isActive = true
        self.sendButton?.bottomAnchor.constraint(equalTo: self.seperatorLine!.topAnchor, constant:-12.0).isActive = true
        sendButtonHeightConstraint = self.sendButton?.heightAnchor.constraint(equalToConstant: 30.0)
        sendButtonHeightConstraint?.isActive = true
    }
    
    override func sendButtonTapped(_ sender: Any?) {
        sendButtonAction?(self.deviceDetails)
    }
}
