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
    
    public static func getUser(_ id: String) throws -> OSTUser? {
        return try OSTUserModelRepository.sharedUser.get(id)
    }
    
    public static func initUser(_ userJson: [String: Any], success: ((OSTUser?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTUserModelRepository.sharedUser.save(userJson, success: success, failure: failure)
    }
    
    public static func getRule(_ id: String) throws -> OSTRule? {
        return try OSTRuleModelRepository.sharedRule.get(id)
    }
    
    public static func initRule(_ ruleJson: [String: Any], success: ((OSTRule?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTRuleModelRepository.sharedRule.save(ruleJson, success: success, failure: failure)
    }
    
    public static func getTokenHolder(_ id: String) throws -> OSTTokenHolder? {
        return try OSTTokenHolderRepository.sharedTokenHolder.get(id)
    }
    
    public static func initTokenHolder(_ tokenHolderJson: [String: Any], success: ((OSTTokenHolder?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTTokenHolderRepository.sharedTokenHolder.save(tokenHolderJson, success: success, failure: failure)
    }
    
    public static func getToken(_ id: String) throws -> OSTToken? {
        return try OSTTokenRepository.sharedToken.get(id)
    }
    
    public static func initToken(_ tokenJson: [String: Any], success: ((OSTToken?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTTokenRepository.sharedToken.save(tokenJson, success: success, failure: failure)
    }
    
    public static func getTokenHolderSession(_ id: String) throws -> OSTTokenHolderSession? {
        return try OSTTokenHolderSessionRepository.sharedTokenHolderSession.get(id)
    }
    
    public static func initTokenHolderSession(_ tokenHolderSessionJson: [String: Any], success: ((OSTTokenHolderSession?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTTokenHolderSessionRepository.sharedTokenHolderSession.save(tokenHolderSessionJson, success: success, failure: failure)
    }
    
    public static func getMultiSig(_ id: String) throws -> OSTMultiSig? {
        return try OSTMultiSigRepository.sharedMultiSig.get(id)
    }
    
    public static func initTokenHolderSession(_ multiSigJson: [String: Any], success: ((OSTMultiSig?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTMultiSigRepository.sharedMultiSig.save(multiSigJson, success: success, failure: failure)
    }
    
    public static func getMultiSigWallet(_ id: String) throws -> OSTMultiSigWallet? {
        return try OSTMultiSigWalletRepository.sharedMultiSigWallet.get(id)
    }
    
    public static func initTokenHolderSession(_ multiSigWalletJson: [String: Any], success: ((OSTMultiSigWallet?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTMultiSigWalletRepository.sharedMultiSigWallet.save(multiSigWalletJson, success: success, failure: failure)
    }
    
    public static func getMultiSigOperation(_ id: String) throws -> OSTMultiSigOperation? {
        return try OSTMultiSigOperationRepository.sharedMultiSigOperation.get(id)
    }
    
    public static func initMultiSigOperation(_ multiSigOperationJson: [String: Any], success: ((OSTMultiSigOperation?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTMultiSigOperationRepository.sharedMultiSigOperation.save(multiSigOperationJson, success: success, failure: failure)
    }
    
    public static func getExecutableRule(_ id: String) throws -> OSTExecutableRule? {
        return try OSTExecutableRuleRepository.sharedExecutableRule.get(id)
    }
    
    public static func initExecutableRule(_ executableRuleJson: [String: Any], success: ((OSTExecutableRule?) -> Void)?, failure: ((Error) -> Void)?) {
        return OSTExecutableRuleRepository.sharedExecutableRule.save(executableRuleJson, success: success, failure: failure)
    }
}
