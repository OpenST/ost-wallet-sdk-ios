/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc public enum OstWorkflowType:Int {
    case setupDevice,
    activateUser,
    addSession,
    getDeviceMnemonics,
    performQRAction,
    executeTransaction,
    authorizeDeviceWithQRCode,
    authorizeDeviceWithMnemonics,
    initiateDeviceRecovery,
    abortDeviceRecovery,
    revokeDevice,
    resetPin,
    logoutAllSessions,
    updateBiometricPreference
}

@objc public class OstWorkflowContext: NSObject {    
    @objc public let workflowType: OstWorkflowType
    let workflowId: String
    
    @objc public init(workflowId: String, workflowType: OstWorkflowType) {
        self.workflowType = workflowType
        self.workflowId = workflowId
    }
    
    @objc public func getWorkflowId() -> String {
        return self.workflowId;
    }
    
    @available(*, deprecated, message: "Please use init(workflowId: String, workflowType: OstWorkflowType)")
    @objc public init(workflowType: OstWorkflowType) {
        self.workflowType = workflowType
        self.workflowId = "UNDEFINED";
    }
}
