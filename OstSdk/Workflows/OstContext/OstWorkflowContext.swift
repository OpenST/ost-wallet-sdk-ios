//
//  OstWorkflowContext.swift
//  OstSdk
//
//  Created by aniket ayachit on 23/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

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
    polling,
    recoverDevice,
    resetPin
}

public class OstWorkflowContext {    
    public let workflowType: OstWorkflowType
    init(workflowType: OstWorkflowType) {
        self.workflowType = workflowType
    }
}
