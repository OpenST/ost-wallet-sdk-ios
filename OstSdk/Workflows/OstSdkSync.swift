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
        case User, CurrentDevice, Token, DeviceManager, Sessions
    }
    
    var userId: String
    var syncEntites: [SyncEntity]
    var forceSync: Bool
    var onCompletion: ((Bool) -> Void)? = nil
    
    var allResponseSuccessed = true
    
    var user: OstUser? = nil
    
    init(userId: String, forceSync: Bool, syncEntites: SyncEntity... , onCompletion:((Bool) -> Void)?) {
        self.userId = userId
        self.syncEntites = syncEntites
        self.forceSync = forceSync
        self.onCompletion = onCompletion
    }
    
    func perform() {
        
        user = try! OstUser.getById(self.userId)!
        
        for syncEntity in syncEntites {
            switch syncEntity {
            case .User:
                syncUser()
            case .Token:
                syncToken()
            case .CurrentDevice:
                syncDevice()
            case .DeviceManager:
                continue
            default:
                continue
            }
        }
    }
    
    func processIfRequired(_ syncEntity: SyncEntity, isSuccess: Bool) {
        
        NSLock().lock()
        let index = self.syncEntites.lastIndex(of: syncEntity)
        if (index != nil) {
            allResponseSuccessed = (allResponseSuccessed && isSuccess)
            self.syncEntites.remove(at: index!)
            if (self.syncEntites.isEmpty) {
                onCompletion?(allResponseSuccessed)
            }
        }
        NSLock().unlock()
    }
    
    //MARK: - Sync User
    func syncUser() {
        if (canSyncUser()) {
            do {
                try OstAPIUser(userId: self.userId).getUser(onSuccess: { (ostUser) in
                    self.processIfRequired(.User, isSuccess: true)
                }, onFailure: { (error) in
                    self.processIfRequired(.User, isSuccess: false)
                    Logger.log(message: "syncUser error:", parameterToPrint: error)
                })
            }catch let error {
                self.processIfRequired(.User, isSuccess: false)
                Logger.log(message: "syncUser error:", parameterToPrint: error)
            }
        }else {
            self.processIfRequired(.User, isSuccess: false)
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
    
    //MARK: - Sync Token
    func syncToken() {
        if (canSyncToken()) {
            do {
                try OstAPITokens(userId: self.userId).getToken(onSuccess: { (ostToken) in
                    self.processIfRequired(.Token, isSuccess: true)
                }, onFailure: { (error) in
                    self.processIfRequired(.Token, isSuccess: false)
                    Logger.log(message: "syncToken error:", parameterToPrint: error)
                })
            }catch let error {
                self.processIfRequired(.Token, isSuccess: false)
                Logger.log(message: "syncToken error:", parameterToPrint: error)
            }
        }else {
            self.processIfRequired(.Token, isSuccess: false)
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
    
    //MARK: - Sync Device
    func syncDevice() {
        if (canSyncDevice()) {
            do {
                try OstAPIDevice(userId: self.userId).getCurrentDevice(onSuccess: { (ostDevice) in
                    self.processIfRequired(.CurrentDevice, isSuccess: true)
                }, onFailure: { (error) in
                    Logger.log(message: "syncToken error:", parameterToPrint: error)
                    self.processIfRequired(.CurrentDevice, isSuccess: false)
                })
            }catch let error {
                Logger.log(message: "syncToken error:", parameterToPrint: error)
                self.processIfRequired(.CurrentDevice, isSuccess: false)
            }
        }else {
            self.processIfRequired(.CurrentDevice, isSuccess: false)
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
