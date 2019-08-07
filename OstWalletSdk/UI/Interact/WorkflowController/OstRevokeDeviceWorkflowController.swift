/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstRevokeDeviceWorkflowController: OstBaseWorkflowController {
    var revokeDeviceAddress: String?
    var deviceListController: OstInitiateRecoveryDLViewController? = nil
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: Ost user id
    ///   - recoverDeviceAddress: Device address to recover
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    @objc
    init(userId: String,
         revokeDeviceAddress: String?,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate) {
        
        self.revokeDeviceAddress = revokeDeviceAddress
        super.init(userId: userId, passphrasePrefixDelegate: passphrasePrefixDelegate);
    }
    
    deinit {
        print("OstRevokeDeviceWorkflowController :: I am deinit");
    }
    
    override func performUIActions() {
        if nil == revokeDeviceAddress {
            self.openAuthorizedDeviceListController()
        }else {
            onDeviceAddressSet()
        }
    }
    
    func openAuthorizedDeviceListController() {
        DispatchQueue.main.async {
            self.deviceListController = OstInitiateRecoveryDLViewController
                .newInstance(userId: self.userId,
                             callBack: {[weak self] (device) in
                                self?.revokeDeviceAddress = (device?["address"] as? String) ?? ""
                                self?.onDeviceAddressSet()
                })
            
            self.deviceListController!.presentVCWithNavigation()
        }
    }
    
    func onDeviceAddressSet() {
        OstWalletSdk.revokeDevice(userId: self.userId,
                                  deviceAddressToRevoke: revokeDeviceAddress!,
                                  delegate: self)
    }
    
}
