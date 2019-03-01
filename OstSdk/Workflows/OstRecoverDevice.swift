//
//  OstRecoverDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 01/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstRecoverDevice: OstWorkflowBase {
    let ostRecoverDeviceThread = DispatchQueue(label: "com.ost.sdk.OstRecoverDevice", qos: .background)
    
    override init(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        
        super.init(userId: userId, delegate: delegate)
    }
    
    /**
    1. initiate recovery
     0. user should be activated state
     1. new device should be in register state.
     2. old device should be in authorized state.
    2.abort recovery
     0. user should be activated state
     1. new device should be in authorizing state.
     2. old device should be in recoving state.
     
     devices = d1, d2, d3(current device)
     
     2. get all device from user.
     3. ask for recover device
     params:
     4. d2 = linked address of device tobe recover
     5. d2 = old device address
     6. d3  = new device address
     7. signer = current user recovery owner address
     8. to = current user recovery address
        8.1 verifyingContract = to
     9. add new typed data
     10. signature = EIP712
     11.

     
     * for abort current user device should be authorizing and old device status should ne recoving.
     polling in case of abort
    */
    
    
    
    
    
    override func perform() {
        ostRecoverDeviceThread.async {
            
        }
    }
}
