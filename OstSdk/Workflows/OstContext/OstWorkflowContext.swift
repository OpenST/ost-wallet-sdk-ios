//
//  OstWorkflowContext.swift
//  OstSdk
//
//  Created by aniket ayachit on 23/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public enum OstWorkflowType1 {
    case setupDevice, activateUser, addDevice, addSession, getPapaerWallet, perform
}

public class OstWorkflowContext {
    
    public let workflowType: OstWorkflowType1
    init(workflowType: OstWorkflowType1) {
        self.workflowType = workflowType
    }
}
