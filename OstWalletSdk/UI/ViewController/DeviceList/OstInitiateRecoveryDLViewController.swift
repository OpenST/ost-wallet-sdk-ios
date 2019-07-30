//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class OstInitiateRecoveryDLViewController: OstDeviceListViewController {
    
    public class func newInstance(userId: String,
                                  callBack: @escaping (([String: Any]?) -> Void)) -> OstInitiateRecoveryDLViewController {
        let instance = OstInitiateRecoveryDLViewController()
        setEssentials(instance: instance,
                      userId: userId,
                      callBack: callBack)
        return instance;
    }
    
    class func setEssentials(instance: OstInitiateRecoveryDLViewController,
                             userId: String,
                             callBack: @escaping (([String: Any]?) -> Void)) {
        instance.onCellSelected = callBack
        instance.userId = userId
    }
    
    override func configure() {
        super.configure()
        
        titleLabel.text = "Device Recovery"
        leadLabel.text = "This is an authorized device, recovery applies only to cases where a user has no authorized device"
    }
}
