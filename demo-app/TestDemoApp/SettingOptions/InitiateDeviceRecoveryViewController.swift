/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

class InitiateDeviceRecoveryViewController: ManageDeviceViewController {
    
    override func getNavBarTitle() -> String {
        return "Initate device recovery"
    }
    
    override func getLeadLabelText() -> String {
        return "Here are your authorized devices"
    }

    
    override func onFetchDeviceSuccess(_ apiResponse: [String : Any]?) {
        isApiCallInProgress = false
                
        meta = apiResponse!["meta"] as? [String: Any]
        guard let resultType = apiResponse!["result_type"] as? String else {return}
        guard let devices = apiResponse![resultType] as? [[String: Any]] else {return}
        var authorizedDevices = [[String: Any]]()
        for device in devices {
            guard let status = device["status"] as? String else {continue}
            if status.caseInsensitiveCompare(DeviceStatus.authorized.rawValue) == .orderedSame  {
                authorizedDevices.append(device)
            }
        }
        tableDataArray.append(contentsOf: authorizedDevices)
        self.isNewDataAvailable = true
        
        reloadDataIfNeeded()
    }
    
    //MARK: - Action
    override func actionButtonTapped(_ entity: [String: Any]) {
        initiateDeviceRecovery(entity: entity)
    }
    
    func initiateDeviceRecovery(entity: [String: Any]) {
        progressIndicator?.progressText = "Initiate device recovery initiated..."
        progressIndicator?.show()
        OstWalletSdk.initiateDeviceRecovery(userId: CurrentUserModel.getInstance.ostUserId!,
                                            recoverDeviceAddress: entity["address"] as! String,
                                            userPin: "123456",
                                            passphrasePrefix: CurrentUserModel.getInstance.userPinSalt!,
                                            delegate: self.workflowDelegate)
    }
}
