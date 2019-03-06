//
//  OstGetPaperWallet.swift
//  OstSdk
//
//  Created by aniket ayachit on 21/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstGetPaperWallet: OstWorkflowBase {
    private let ostGetPaperWalletQueue = DispatchQueue(label: "com.ost.sdk.OstGetPaperWallet", qos: .background)
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostGetPaperWalletQueue
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
                
                DispatchQueue.main.async {
                    self.delegate.showPaperWallet(mnemonics: mnemonics)
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
