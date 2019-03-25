/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstGetPaperWallet: OstWorkflowBase {
    static private let ostGetPaperWalletQueue = DispatchQueue(label: "com.ost.sdk.OstGetPaperWallet", qos: .userInitiated)
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstGetPaperWallet.ostGetPaperWalletQueue
    }
    
    /// validate parameters
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        
        try self.workFlowValidator!.isUserActivated()
    }
    
    /// process workflow
    ///
    /// - Throws: OstError
    override func process() throws {
         self.authenticateUser()
    }
    
    /// Proceed with workflow after user is authenticated.
    override func proceedWorkflowAfterAuthenticateUser() {
        let queue: DispatchQueue = getWorkflowQueue()
        queue.async {
            do {
                let keychainManager = OstKeyManager(userId: self.userId)
                guard let mnemonics: [String] = try keychainManager.getDeviceMnemonics() else {
                    throw OstError("w_gpw_pwaau_1", .paperWalletNotFound)
                }
                
                self.postWorkflowComplete(entity: mnemonics)
                
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .getPaperWallet)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .array)
    }
}
