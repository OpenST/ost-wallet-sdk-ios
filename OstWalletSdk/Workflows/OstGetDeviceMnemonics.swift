/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstGetDeviceMnemonics: OstUserAuthenticatorWorkflow {
    static private let ostGetDeviceMnemonicsQueue = DispatchQueue(label: "com.ost.sdk.OstGetDeviceMnemonics", qos: .userInitiated)
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstGetDeviceMnemonics.ostGetDeviceMnemonicsQueue
    }
    
    /// Perform user device validation
    ///
    /// - Throws: OstError
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        try isUserActivated()
    }
    
    /// Get device mnemonics after user authenticated
    override func onUserAuthenticated() throws {
        guard let mnemonics: [String] = try OstKeyManagerGateway
            .getOstKeyManager(userId: self.userId)
            .getDeviceMnemonics() else {
                
                throw OstError("w_gpw_pwaau_1", .paperWalletNotFound)
        }
        
        self.postWorkflowComplete(entity: mnemonics)
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .getDeviceMnemonics)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .array)
    }
}
