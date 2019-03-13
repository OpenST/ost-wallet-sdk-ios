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
    
    /// Initialize.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - forceSync: Can for sync entity.
    ///   - syncEntites: Entities to sync.
    ///   - onCompletion: Callback
    init(userId: String, forceSync: Bool, syncEntites: SyncEntity... , onCompletion:((Bool) -> Void)?) {
        self.userId = userId
        self.syncEntites = syncEntites
        self.forceSync = forceSync
        self.onCompletion = onCompletion
    }
    
    /// Decide which polling flow to perform
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
    
    /// Process completion of sync entity
    ///
    /// - Parameters:
    ///   - syncEntity: Entity type which is synced.
    ///   - isSuccess: Sync is successed or not.
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
                    // Logger.log(message: "syncUser error:", parameterToPrint: error)
                })
            }catch {
                self.processIfRequired(.User, isSuccess: false)                
            }
        }else {
            self.processIfRequired(.User, isSuccess: false)
        }
    }
    
    /// Check whether user needed tobe synced.
    ///
    /// - Returns: true if user entity need to be synced.
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
                    // Logger.log(message: "syncToken error:", parameterToPrint: error)
                })
            }catch {
                self.processIfRequired(.Token, isSuccess: false)
            }
        }else {
            self.processIfRequired(.Token, isSuccess: false)
        }
    }
    
    /// Check whether token needed tobe synced.
    ///
    /// - Returns:  true if token entity need to be synced.
    func canSyncToken() -> Bool {
        if (self.forceSync) {
            return true
        }
        do {
            let token: OstToken? = try OstTokenRepository.sharedToken.getById(user!.tokenId!) as? OstToken
            if (token?.auxiliaryChainId != nil) {
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
                    // Logger.log(message: "syncToken error:", parameterToPrint: error)
                    self.processIfRequired(.CurrentDevice, isSuccess: false)
                })
            }catch {
                self.processIfRequired(.CurrentDevice, isSuccess: false)
            }
        }else {
            self.processIfRequired(.CurrentDevice, isSuccess: false)
        }
    }
    
    /// Check whether device needed tobe synced.
    ///
    /// - Returns: true if device entity need to be synced.
    func canSyncDevice() -> Bool {
        if (self.forceSync) {
            return true
        }
       
        let currentDevice = user!.getCurrentDevice()
        if (currentDevice != nil && !currentDevice!.isStatusRegistered) {
            return false
        }
        
        return true
    }
}
