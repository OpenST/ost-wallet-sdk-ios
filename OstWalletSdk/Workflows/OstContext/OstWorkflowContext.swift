/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

public enum OstWorkflowType {
    case SETUP_DEVICE,
    ACTIVATE_USER,
    ADD_SESSISON,
    GET_DEVICE_MNEMONICS,
    PERFORM_QR_ACTION,
    EXECUTE_TRANSACTION,
    ADD_DEVICE_WITH_QR_CODE,
    ADD_DEVICE_WITH_MNEMONICS,
    INITIATE_DEVICE_RECOVERY,
    ABORT_DEVICE_RECOVERY,
    REVOKE_DEVICE_WITH_QR_CODE,
    RESET_PIN,
    LOGOUT_ALL_SESSIONS,
    POLLING
}

public class OstWorkflowContext {    
    public let workflowType: OstWorkflowType
    init(workflowType: OstWorkflowType) {
        self.workflowType = workflowType
    }
}
