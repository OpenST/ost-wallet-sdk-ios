//
//  OstDeployTokenHolder.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstDeployTokenHolder: OstWorkflowBase, OstPinAcceptProtocol, OstDeviceRegisteredProtocol {
    
    var delegate: OstWorkFlowCallbackProtocol?
    var uPin: String
    var password: String
    var handler: (OstDeployTokenHolder) -> Void
    
    var userId: String = ""
    
    init(pin: String, password: String, handler: @escaping (OstDeployTokenHolder) -> Void, delegate: OstWorkFlowCallbackProtocol) {
        self.delegate = delegate
        self.uPin = pin
        self.password = password
        self.handler = handler
        
        super.init(OstKeyGenerationParams())
    }
    
    func perform() {
        
    }
    
    public func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        print("uPin: \(uPin) and appUserPassword: \(appUserPassword)")
    }
    
    //MARK: - OstDeviceRegisteredProtocol
    public func deviceRegistered(_ apiResponse: [String : Any]) {
        
    }
    
    public func cancelFlow(_ cancelReason: String) {
        
    }
}
