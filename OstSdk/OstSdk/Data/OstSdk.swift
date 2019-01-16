//
//  OstSdk.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstSdk {
    private init() {}
    
    public static func getUser(_ id: String) throws -> OstUser? {
        return try OstUserModelRepository.sharedUser.get(id)
    }
    
    public static func initUser(_ userJson: [String: Any], success: ((OstUser?) -> Void)?, failure: ((Error) -> Void)?) {
        return OstUserModelRepository.sharedUser.save(userJson, success: success, failure: failure)
    }
    
    public static func getRule(_ id: String) throws -> OstRule? {
        return try OstRuleModelRepository.sharedRule.get(id)
    }
    
    public static func initRule(_ ruleJson: [String: Any], success: ((OstRule?) -> Void)?, failure: ((Error) -> Void)?) {
        return OstRuleModelRepository.sharedRule.save(ruleJson, success: success, failure: failure)
    }
    
    public static func getTokenHolder(_ id: String) throws -> OstTokenHolder? {
        return try OstTokenHolderRepository.sharedTokenHolder.get(id)
    }
    
    public static func initTokenHolder(_ tokenHolderJson: [String: Any], success: ((OstTokenHolder?) -> Void)?, failure: ((Error) -> Void)?) {
        return OstTokenHolderRepository.sharedTokenHolder.save(tokenHolderJson, success: success, failure: failure)
    }
    
    public static func getToken(_ id: String) throws -> OstToken? {
        return try OstTokenRepository.sharedToken.get(id)
    }
    
    public static func initToken(_ tokenJson: [String: Any], success: ((OstToken?) -> Void)?, failure: ((Error) -> Void)?) {
        return OstTokenRepository.sharedToken.save(tokenJson, success: success, failure: failure)
    }
    
    public static func getTokenHolderSession(_ id: String) throws -> OstTokenHolderSession? {
        return try OstTokenHolderSessionRepository.sharedTokenHolderSession.get(id)
    }
    
    public static func initTokenHolderSession(_ tokenHolderSessionJson: [String: Any], success: ((OstTokenHolderSession?) -> Void)?, failure: ((Error) -> Void)?) {
        return OstTokenHolderSessionRepository.sharedTokenHolderSession.save(tokenHolderSessionJson, success: success, failure: failure)
    }
    
    public static func getMultiSig(_ id: String) throws -> OstMultiSig? {
        return try OstMultiSigRepository.sharedMultiSig.get(id)
    }
    
    public static func initMultiSig(_ multiSigJson: [String: Any], success: ((OstMultiSig?) -> Void)?, failure: ((Error) -> Void)?) {
        return OstMultiSigRepository.sharedMultiSig.save(multiSigJson, success: success, failure: failure)
    }
    
    public static func getMultiSigWallet(_ id: String) throws -> OstMultiSigWallet? {
        return try OstMultiSigWalletRepository.sharedMultiSigWallet.get(id)
    }
    
    public static func initMultiSigWallet(_ multiSigWalletJson: [String: Any], success: ((OstMultiSigWallet?) -> Void)?, failure: ((Error) -> Void)?) {
        return OstMultiSigWalletRepository.sharedMultiSigWallet.save(multiSigWalletJson, success: success, failure: failure)
    }
    
    public static func getMultiSigOperation(_ id: String) throws -> OstMultiSigOperation? {
        return try OstMultiSigOperationRepository.sharedMultiSigOperation.get(id)
    }
    
    public static func initMultiSigOperation(_ multiSigOperationJson: [String: Any], success: ((OstMultiSigOperation?) -> Void)?, failure: ((Error) -> Void)?) {
        return OstMultiSigOperationRepository.sharedMultiSigOperation.save(multiSigOperationJson, success: success, failure: failure)
    }
    
    public static func getExecutableRule(_ id: String) throws -> OstExecutableRule? {
        return try OstExecutableRuleRepository.sharedExecutableRule.get(id)
    }
    
    public static func initExecutableRule(_ executableRuleJson: [String: Any], success: ((OstExecutableRule?) -> Void)?, failure: ((Error) -> Void)?) {
        return OstExecutableRuleRepository.sharedExecutableRule.save(executableRuleJson, success: success, failure: failure)
    }
}
