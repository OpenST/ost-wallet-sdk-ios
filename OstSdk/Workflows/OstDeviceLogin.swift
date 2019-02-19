//
//  OstDeviceLogin.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstDeviceLogin: OstPinAcceptProtocol, OstDeviceRegisteredProtocol, OstStartPollingProtocol {
   
    init() { }
    
    //MARK: - OstPinAcceptProtocol
    public func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        
    }
    
    //MARK: - OstDeviceRegisteredProtocol
    public func deviceRegistered(_ apiResponse: [String : Any]) {
        
    }
    
    //MARK: - OstStartPollingProtocol
    public func startPolling() {
        
    }
    
    public func cancelFlow(_ cancelReason: String) {
        
    }
}
