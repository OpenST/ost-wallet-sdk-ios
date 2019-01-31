//
//  OstWorkFlowFactory.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstWorkFlowFactory {
    
    public static func deployTokenHolder(pin: String, password: String, delegate: OstWorkFlowCallbackProtocol) {
        let deployTokenHolderThread = DispatchQueue(label: "com.ost.sdk.deployTokenHolder", qos: .background)
        
        let deployTokenHolderCompletionHandler: (OstDeployTokenHolder) -> Void = {ostDeployTokenHolder in
            print("here")
            delegate.getPin(ostDeployTokenHolder.userId, delegate: ostDeployTokenHolder)
        }
        let ostDeployTokenHolder: OstDeployTokenHolder = OstDeployTokenHolder(pin: pin, password: password, handler: deployTokenHolderCompletionHandler, delegate: delegate)
        deployTokenHolderThread.async {
            ostDeployTokenHolder.perform()
        }
    }
    
    
}
