/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstBiometricPreference: OstUserAuthenticatorWorkflow {
    
    let enable: Bool
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - enable: Enable biometric
    ///   - delegate: Callback
    init(userId: String,
                  enable: Bool,
                  delegate: OstWorkflowDelegate) {
        
        self.enable = enable
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Should ask for biometric authentication
    override func shouldAskForBiometricAuthentication() -> Bool {
        return false
    }
    
    /// Proceed with workflow after user is authenticated.
    override func onUserAuthenticated() throws {
        let biometricManager = OstKeyManagerGateway.getOstBiometricManager(userId: self.userId)
        if enable {
            try biometricManager.enableBiometric()
        }else {
            try biometricManager.disableBiometric()
        }
        
        self.postWorkflowComplete(entity: enable)
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .updateBiometricPreference)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .boolean)
    }
    
}
