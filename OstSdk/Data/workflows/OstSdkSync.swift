//
//  OstSdkSync.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSdkSync {
    
    enum SyncEntity: String {
        case User, Devices, Token, DeviceManager, Sessions
    }
    
    var userId: String
    var syncEntites: [SyncEntity?]
    var forceSync: Bool
    var onCompletion: ((Bool) -> Void)? = nil
    
    init(userId: String, forceSync: Bool, syncEntites: SyncEntity?... , onCompletion:((Bool) -> Void)?) {
        self.userId = userId
        self.syncEntites = syncEntites
        self.forceSync = forceSync
        self.onCompletion = onCompletion
    }
    
    func perform() {
        if (!syncEntites.isEmpty) {
            for syncEntity in syncEntites {
                switch syncEntity {
                case .User?:
                    syncUser()
                case .Token?:
                    syncToken()
                case .Devices?:
                    continue
                case .DeviceManager?:
                    continue
                default:
                    continue
                }
            }
        }
    }
    
    func processIfRequired(_ syncEntity: SyncEntity) {
        NSLock().lock()
        let index = self.syncEntites.lastIndex(of: syncEntity)
        if (index != nil) {
            self.syncEntites.remove(at: index!)
            
            if (self.syncEntites.isEmpty) {
                onCompletion?(true)
            }
        }
        NSLock().unlock()
    }
    
    //MARK: - Sync entities
    func syncUser() {
        do {
            try OstAPIUser(userId: self.userId).getUser(success: { (ostUser) in
                self.processIfRequired(.User)
            }, failuar: { (error) in
                Logger.log(message: "syncUser error:", parameterToPrint: error)
            })
        }catch let error {
            Logger.log(message: "syncUser error:", parameterToPrint: error)
        }
    }
    
    func syncToken() {
        do {
            try OstAPITokens(userId: self.userId).getToken(success: { (ostToken) in
                self.processIfRequired(.Token)
            }, failuar: { (error) in
                 Logger.log(message: "syncToken error:", parameterToPrint: error)
            })
        }catch let error {
            Logger.log(message: "syncToken error:", parameterToPrint: error)
        }
    }
    
}
