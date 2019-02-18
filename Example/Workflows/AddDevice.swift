//
//  AddDevice.swift
//  Example
//
//  Created by aniket ayachit on 18/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk

class AddDevice: OstWorkFlowCallbackImplementation {
    
    let userId: String
    init(mappyUserId: String, userId: String) {
        self.userId = userId
        super.init(mappyUserId: mappyUserId)
    }
    
    func perform() {
        OstSdk.addDevice(userId: self.userId, delegate: self)
    }
    
    override func determineAddDeviceWorkFlow(_ ostAddDeviceFlowProtocol: OstAddDeviceFlowProtocol) {
        ostAddDeviceFlowProtocol.QRCodeFlow()
    }
    
    override func showQR(_ startPollingProtocol: OstStartPollingProtocol, image qrImage: CIImage) {
        OstSdk.perform(userId: "34db9f21-9cc1-47d8-9819-f951168badf0",  ciImage: qrImage, delegate: self)
    }
}
