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
//    public static func getMultiSig(_ id: String) throws -> OstDeviceManager? {
//        return try OstDeviceManagerRepository.sharedDeviceManager.getById(id) as? OstDeviceManager
//    }
//
//    public static func initMultiSig(_ entityData: [String: Any]) throws -> OstDeviceManager? {
//        let entity: OstDeviceManager = try OstDeviceManager(entityData)
//        return OstDeviceManagerRepository.sharedDeviceManager.insertOrUpdate((entity as OstBaseEntity)) as? OstDeviceManager
//    }
//
//    public static func getMultiSigWallet(_ id: String) throws -> OstDevice? {
//        return try OstDeviceRepository.sharedDevice.getById(id) as? OstDevice
//    }
//
//    public static func initMultiSigWallet(_ entityData: [String: Any]) throws -> OstDevice? {
//        let entity: OstDevice = try OstDevice(entityData)
//        return OstDeviceRepository.sharedDevice.insertOrUpdate((entity as OstBaseEntity)) as? OstDevice
//    }
//
//    public static func getMultiSigOperation(_ id: String) throws -> OstDeviceManagerOperation? {
//        return try OstDeviceManagerOperationRepository.sharedDeviceManagerOperation.getById(id) as? OstDeviceManagerOperation
//    }
//
//    public static func initMultiSigOperation(_ entityData: [String: Any]) throws -> OstDeviceManagerOperation? {
//        let entity: OstDeviceManagerOperation = try OstDeviceManagerOperation(entityData)
//        return OstDeviceManagerOperationRepository.sharedDeviceManagerOperation.insertOrUpdate((entity as OstBaseEntity)) as? OstDeviceManagerOperation
//    }
//
//    public static func getExecutableRule(_ id: String) throws -> OstTransaction? {
//        return try OstTransactionRepository.sharedExecutableRule.getById(id) as? OstTransaction
//    }
//
//    public static func initExecutableRule(_ entityData: [String: Any]) throws -> OstTransaction? {
//        let entity: OstTransaction = try OstTransaction(entityData)
//        return OstTransactionRepository.sharedExecutableRule.insertOrUpdate((entity as OstBaseEntity)) as? OstTransaction
//    }
    
}
