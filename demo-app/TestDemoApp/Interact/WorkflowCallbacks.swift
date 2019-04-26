/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class WorkflowCallbacks: OstWorkflowDelegate {
    let workflowId: String
    
    private var interact: SdkInteract {
        return SdkInteract.getInstance
    }
    
    init() {
        self.workflowId = String(Int(Date().timeIntervalSince1970))
    }
    
    func registerDevice(_ apiParams: [String : Any], delegate: OstDeviceRegisteredDelegate) {
        
    }
    
    func getPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        
    }
    
    func invalidPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        
    }
    
    func pinValidated(_ userId: String) {
        
    }
    
    func flowComplete(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        
    }
    
    func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
        
    }
    
    func verifyData(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity, delegate: OstValidateDataDelegate) {
        
    }
    
    func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        
    }
}
