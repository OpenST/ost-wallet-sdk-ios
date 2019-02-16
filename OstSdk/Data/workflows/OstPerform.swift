//
//  OstPerform.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstPerform: OstWorkflowBase {
    let ostPerformThread = DispatchQueue(label: "com.ost.sdk.OstPerform", qos: .background)
    
    let multiSigDataString: String
    init(userId: String, multiSigDataString: String, delegate: OstWorkFlowCallbackProtocol) {
        self.multiSigDataString = multiSigDataString
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        ostPerformThread.async {
            do {
                try self.validateParams()
                
//                let encodedABI = GenosisSafe().getAddOwnerWithThresholdExecutableData(ownerAddress: <#T##String#>)
                
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    func validateParams() {
        
    }
}
