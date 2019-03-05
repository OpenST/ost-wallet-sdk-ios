//
//  OstGetPaperWallet.swift
//  OstSdk
//
//  Created by aniket ayachit on 21/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstGetPaperWallet: OstWorkflowBase {
    let ostGetPaperWalletThread = DispatchQueue(label: "com.ost.sdk.OstGetPaperWallet", qos: .background)
    
    override init(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        super.init(userId: userId, delegate: delegate)
    }
    
    override func getWorkflowThread() -> DispatchQueue {
        return self.ostGetPaperWalletThread
    }
    
    override func process() throws {
         self.authenticateUser()
    }
    
    override func validateParams() throws {
        try super.validateParams()
        
        if (!self.currentUser!.isStatusActivated) {
            throw OstError("w_as_vp_1", .userNotActivated)
        }
    }
  
    
    override func proceedWorkflowAfterAuthenticateUser() {
        let thread: DispatchQueue = getWorkflowThread()
        thread.async {
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
