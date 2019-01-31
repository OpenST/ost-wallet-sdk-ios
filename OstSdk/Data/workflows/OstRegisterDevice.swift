//
//  OstRegisterDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstRegisterDevice: OstDeviceRegisteredProtocol {
   
    init(pin uPin: String, password: String, callback: OstWorkFlowCallbackProtocol) {
        
    }
    
    func perform(){
        
    }
    
    //MARK: - OstDeviceRegisteredProtocol
    public func deviceRegistered(_ apiResponse: [String : Any]) {
        
    }
    
    public func cancelFlow(_ cancelReason: String) {
        
    }
}
