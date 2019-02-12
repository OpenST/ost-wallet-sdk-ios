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
    
    var user: OstUser? = nil
    
    init(userId: String, forceSync: Bool, syncEntites: SyncEntity?... , onCompletion:((Bool) -> Void)?) {
        self.userId = userId
        self.syncEntites = syncEntites
        self.forceSync = forceSync
        self.onCompletion = onCompletion
    }
    
    func perform() {
        
        user = try! OstUserModelRepository.sharedUser.getById(self.userId) as! OstUser
        
        for syncEntity in syncEntites {
            switch syncEntity {
            case .User?:
                syncUser()
            case .Token?:
                syncToken()
            case .Devices?:
                syncDevice()
            case .DeviceManager?:
                continue
            default:
                continue
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
    
    //MARK: - Sync User
    func syncUser() {
        if (canSyncUser()) {
            do {
                try OstAPIUser(userId: self.userId).getUser(success: { (ostUser) in
                    self.processIfRequired(.User)
                }, failuar: { (error) in
                    Logger.log(message: "syncUser error:", parameterToPrint: error)
                })
            }catch let error {
                Logger.log(message: "syncUser error:", parameterToPrint: error)
            }
        }else {
            
        }
    }
    
    func canSyncUser() -> Bool {
        if (self.forceSync) {
            return true
        }
        
        if (user != nil &&
            user!.tokenHolderAddress != nil &&
            user!.deviceManagerAddress != nil) {
            return false
        }
        return true
    }
    
    //MAKR: - Sync Token
    func syncToken() {
        if (canSyncToken()) {
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
    
    func canSyncToken() -> Bool {
        if (self.forceSync) {
            return true
        }
        do {
            let token: OstToken? = try OstTokenRepository.sharedToken.getById(user!.tokenId!) as? OstToken
            if (token?.totalSupply != nil) {
                return false
            }
        }catch {  }
        return true
    }
    
    //MAKR: - Sync Device
    func syncDevice() {
        if (canSyncDevice()) {
            do {
                try OstAPIDevice(userId: self.userId).getDevice(success: { (ostDevice) in
                    self.processIfRequired(.Devices)
                }, failuar: { (error) in
                    Logger.log(message: "syncToken error:", parameterToPrint: error)
                })
            }catch let error {
                Logger.log(message: "syncToken error:", parameterToPrint: error)
            }
        }
    }
    
    func canSyncDevice() -> Bool {
        if (self.forceSync) {
            return true
        }
        
        let currentDevice = user!.getCurrentDevice()
        if (currentDevice != nil && !currentDevice!.isDeviceRevoked() &&
            currentDevice!.isDeviceRegistered()) {
            return false
        }
        
        return true
    }
}
