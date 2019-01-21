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
        return try OstUserModelRepository.sharedUser.getById(id) as? OstUser
    }
    
    public static func parseUser(_ entityData: [String: Any?]) throws -> OstUser? {
        return try OstUser.parse(entityData);
    }
    
    public static func initUser(forId id: String) throws -> OstUser? {
        let entityData: [String: Any] = ["id": id]
        return try parseUser(entityData)
    }
    
    public static func parseUser(_ jsonString: String) throws -> OstUser? {
        let entityData = try jsonString.toDictionary()
        return try parseUser(entityData)
    }
    
    public static func getRule(_ id: String) throws -> OstRule? {
        return try OstRuleModelRepository.sharedRule.getById(id) as? OstRule
    }
    
//    public static func initRule(_ entityData: [String: Any]) throws -> OstRule? {
//        let entity: OstRule = try OstRule(entityData)
//        return OstUserModelRepository.sharedUser.insertOrUpdate((entity as OstBaseEntity)) as? OstRule
//    }
//
//    public static func getTokenHolder(_ id: String) throws -> OstTokenHolder? {
//        return try OstTokenHolderRepository.sharedTokenHolder.getById(id) as? OstTokenHolder
//    }
//
//    public static func initTokenHolder(_ entityData: [String: Any]) throws -> OstTokenHolder? {
//        let entity: OstTokenHolder = try OstTokenHolder(entityData)
//        return OstTokenHolderRepository.sharedTokenHolder.insertOrUpdate((entity as OstBaseEntity)) as? OstTokenHolder
//    }
//
//    public static func getToken(_ id: String) throws -> OstToken? {
//        return try OstTokenRepository.sharedToken.getById(id) as? OstToken
//    }
//
//    public static func initToken(_ entityData: [String: Any]) throws -> OstToken? {
//        let entity: OstToken = try OstToken(entityData)
//        return OstTokenRepository.sharedToken.insertOrUpdate((entity as OstBaseEntity)) as? OstToken
//    }
//
//    public static func getTokenHolderSession(_ id: String) throws -> OstTokenHolderSession? {
//        return try OstTokenHolderSessionRepository.sharedTokenHolderSession.getById(id) as? OstTokenHolderSession
//    }
//
//    public static func initTokenHolderSession(_ entityData: [String: Any]) throws -> OstTokenHolderSession? {
//        let entity: OstTokenHolderSession = try OstTokenHolderSession(entityData)
//        return OstTokenHolderSessionRepository.sharedTokenHolderSession.insertOrUpdate((entity as OstBaseEntity)) as? OstTokenHolderSession
//    }
//
//    public static func getMultiSig(_ id: String) throws -> OstMultiSig? {
//        return try OstMultiSigRepository.sharedMultiSig.getById(id) as? OstMultiSig
//    }
//
//    public static func initMultiSig(_ entityData: [String: Any]) throws -> OstMultiSig? {
//        let entity: OstMultiSig = try OstMultiSig(entityData)
//        return OstMultiSigRepository.sharedMultiSig.insertOrUpdate((entity as OstBaseEntity)) as? OstMultiSig
//    }
//
//    public static func getMultiSigWallet(_ id: String) throws -> OstMultiSigWallet? {
//        return try OstMultiSigWalletRepository.sharedMultiSigWallet.getById(id) as? OstMultiSigWallet
//    }
//
//    public static func initMultiSigWallet(_ entityData: [String: Any]) throws -> OstMultiSigWallet? {
//        let entity: OstMultiSigWallet = try OstMultiSigWallet(entityData)
//        return OstMultiSigWalletRepository.sharedMultiSigWallet.insertOrUpdate((entity as OstBaseEntity)) as? OstMultiSigWallet
//    }
//
//    public static func getMultiSigOperation(_ id: String) throws -> OstMultiSigOperation? {
//        return try OstMultiSigOperationRepository.sharedMultiSigOperation.getById(id) as? OstMultiSigOperation
//    }
//
//    public static func initMultiSigOperation(_ entityData: [String: Any]) throws -> OstMultiSigOperation? {
//        let entity: OstMultiSigOperation = try OstMultiSigOperation(entityData)
//        return OstMultiSigOperationRepository.sharedMultiSigOperation.insertOrUpdate((entity as OstBaseEntity)) as? OstMultiSigOperation
//    }
//
//    public static func getExecutableRule(_ id: String) throws -> OstExecutableRule? {
//        return try OstExecutableRuleRepository.sharedExecutableRule.getById(id) as? OstExecutableRule
//    }
//
//    public static func initExecutableRule(_ entityData: [String: Any]) throws -> OstExecutableRule? {
//        let entity: OstExecutableRule = try OstExecutableRule(entityData)
//        return OstExecutableRuleRepository.sharedExecutableRule.insertOrUpdate((entity as OstBaseEntity)) as? OstExecutableRule
//    }
    
}
