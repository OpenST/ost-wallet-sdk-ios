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
    addDevice,
    addSession,
    getPaperWallet,
    perform,
    showQRCode,
    executeTransaction,
    scanQRCode,
    addDeviceWithQRCode,
    addDeviceWithMnemonics,
    polling,
    recoverDevice,
    abortRecoverDevice,
    resetPin
}

public class OstWorkflowContext {    
    public let workflowType: OstWorkflowType
    init(workflowType: OstWorkflowType) {
        self.workflowType = workflowType
    }
}
