//
//  OstWorkFlowCallbackImplementation.swift
//  Example
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk

class OstWorkFlowCallbackImplementation: OstWorkFlowCallbackProtocol {
 
    init() { }
    
    func registerDevice(_ apiParams: [String : Any], delegate ostDeviceRegisteredProtocol: OstDeviceRegisteredProtocol) {
        let registerDeviceResponse = ["device": [
                                                "user_id": "abcd-kdlk",
                                                "address": "0x123",
                                                "personal_sign_address": "0x123",
                                                "device_name": apiParams["device_name"],
                                                "device_uuid": apiParams["device_uuid"],
                                                "status": "REGISTERED",
                                                "updated_timestamp": Date().timeIntervalSince1970
                                                ]
                                     ]
        do {
            try ostDeviceRegisteredProtocol.deviceRegistered(registerDeviceResponse)
        }catch let error{
            print(error)
        }
        
    }
    
    func getPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol) {
        
    }
    
    func invalidPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol) {
        
    }
    
    func pinValidated(_ userId: String) {
        
    }
    
    func flowComplete(_ ostContextEntity: OstContextEntity) {
        
    }
    
    func flowInterrupt(_ ostError: OstError) {
        
    }
    
    func determineAddDeviceWorkFlow(_ ostAddDeviceFlowProtocol: OstAddDeviceFlowProtocol) {
        
    }
    
    func showQR(_ startPollingProtocol: OstStartPollingProtocol, image qrImage: CIImage) {
        
    }
    
    func getWalletWords(_ ostWalletWordsAcceptProtocol: OstWalletWordsAcceptProtocol) {
        
    }
    
    func invalidWalletWords(_ ostWalletWordsAcceptProtocol: OstWalletWordsAcceptProtocol) {
        
    }
    
    func walletWordsValidated() {
        
    }
}
