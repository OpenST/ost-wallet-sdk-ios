/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

public enum OstWorkflowType {
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
    revokeDeviceWithQRCode,
    resetPin,
    logoutAllSessions,
    updateBiometricPreference
}

public class OstWorkflowContext {    
    public let workflowType: OstWorkflowType
    public init(workflowType: OstWorkflowType) {
        self.workflowType = workflowType
    }
}
