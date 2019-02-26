//
//  OstGetPapaerWallet.swift
//  OstSdk
//
//  Created by aniket ayachit on 21/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstGetPapaerWallet: OstWorkflowBase {
    let ostGetPapaerWalletThread = DispatchQueue(label: "com.ost.sdk.OstGetPapaerWallet", qos: .background)
    
    override init(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        ostGetPapaerWalletThread.async {
            self.authenticateUser()
        }
    }
    
    override func proceedWorkflowAfterAuthenticateUser() {
        do {
            let keychainManager = OstKeyManager(userId: self.userId)
            
            guard let mnemonics: [String] = try keychainManager.getDeviceMnemonics() else {
                throw OstError("w_gpw_pwaau_1", .paperWalletNotFound)                
            }
            
            DispatchQueue.main.async {
                self.delegate.showPaperWallet(mnemonics: mnemonics)
            }
            
        }catch let error {
            self.postError(error)
        }
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .getPapaerWallet)
    }
    
    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .array)
    }
}
