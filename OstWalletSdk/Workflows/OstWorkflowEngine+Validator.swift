/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

extension OstWorkflowEngine {
    
    /// Check if the given input is valid number
    ///
    /// - Parameter input: Input string
    /// - Throws: OstError
    func isValidNumber(input: String) -> Bool {
        if input.isEmpty {
            return false
        }
        guard let _ = BigInt(input) else {
            return false
        }
        return true
    }
    
    // MARK: - Device related validations
    
    /// Is device status authorizes
    ///
    /// - Throws: OstError
    func isDeviceAuthorized() throws {
        let currentDevice = try self.getCurrentUserDevice()
        if !currentDevice.isStatusAuthorized {
            throw OstError("w_wfv_ida_1", .deviceNotAuthorized)
        }
    }
    
    /// Is device status registered.
    ///
    /// - Throws: OstError
    func isDeviceRegistered() throws {
        let currentDevice = try self.getCurrentUserDevice()
        if !currentDevice.isStatusRegistered {
            throw OstError("w_wfv_idr_1", .deviceNotSet)
        }
    }
    
    // MARK: - User related validations
    
    /// Is user activated
    ///
    /// - Throws: OstError
    func isUserActivated() throws {
        if (!self.currentUser!.isStatusActivated) {
            throw OstError("w_wfv_iua_1", .userNotActivated)
        }
    }
    
    // MARK: - Other validations
    
    /// Validate recovery owner address
    ///
    /// - Parameter recoveryOwnerAddress: Recovery owner address
    /// - Throws: OstError
    func validateRecoveryOwnerAddress(_ recoveryOwnerAddress: String?) throws {
        if (nil == recoveryOwnerAddress
            || recoveryOwnerAddress!.isEmpty) {
            throw OstError("w_wfv_vroa_1", .recoveryOwnerAddressNotFound)
        }
    }
    
    /// Check whether api key is available or not
    ///
    /// - Throws: OstError
    func isAPIKeyAvailable() throws {
        guard let apiAddress = OstKeyManagerGateway
            .getOstKeyManager(userId: self.currentUser!.id)
            .getAPIAddress() else {
                throw OstError("w_wfv_ialv_1", .apiAddressNotFound)
        }
        if (apiAddress.isEmpty) {
            throw OstError("w_wfv_ialv_2", .apiAddressNotFound)
        }
    }
    
    /// Check whether token entity is present or not
    ///
    /// - Throws: OstError
    func isTokenAvailable() throws {
        guard let tokenId = self.currentUser!.tokenId else {
            throw OstError("w_wfv_ita_1", .invalidTokenId)
        }
        let _ = try OstToken.getById(tokenId)
    }
    
    /// Get current device from database
    ///
    /// - Returns: Current device entity
    /// - Throws: OstError
    private func getCurrentUserDevice() throws -> OstCurrentDevice{
        guard let currentDevice = self.currentUser!.getCurrentDevice() else {
            throw OstError("w_wv_gcud_1", .deviceNotSet);
        }
        return currentDevice
    }
    
    //MARK: - Ensure API Communication
    
    /// Ensure API communication
    ///
    /// - Throws: OstError
    func ensureApiCommunication() throws {
        if(nil == self.currentUser) {
            throw OstError("w_wev_eac_1", .deviceNotSet)
        }
        
        if(nil == self.currentDevice) {
            throw OstError("w_wev_eac_2", .deviceNotSet)
        }
        
        if (!canDeviceMakeApiCall(ostDevice: self.currentDevice!)) {
            let deviceAddress = self.currentDevice!.address!
            do {
                try syncCurrentDevice()
            }catch let error {
                let ostError: OstError = error as! OstError
                if ostError.isApiError {
                    if (ostError as! OstApiError).isApiSignerUnauthorized() {
                        throw OstError("w_wev_eac_3", .deviceNotSet)
                    }
                }
                throw ostError
            }
            
            if let ostDevice = try OstDevice.getById(deviceAddress) {
                if !canDeviceMakeApiCall(ostDevice: ostDevice) {
                    throw OstError("w_wev_eac_4", .deviceNotSet)
                }
            }
            throw OstError("w_wev_eac_5", .deviceNotSet)
        }
    }
    
    /// Check whether device can make api calls
    ///
    /// - Parameter ostDevice: OstDevice
    /// - Returns: `true` if device can make api call else `false`
    func canDeviceMakeApiCall(ostDevice: OstDevice) -> Bool {
        //Must have Device Api Key which should have been registered.
        do {
            try isAPIKeyAvailable()
        }catch {
            return false
        }
        return ostDevice.canMakeApiCall();
    }
    
    /// Fetch current device from server
    ///
    /// - Throws: OstError
    func syncCurrentDevice() throws {
        var err: OstError? = nil
        let group = DispatchGroup()
      print("debug print :: syncCurrentDevice :: getting current deivce from server");
        group.enter()
        try OstAPIDevice(userId: self.userId).getCurrentDevice(onSuccess: { (device) in
            group.leave()
        }) { (error) in
            err = error
            group.leave()
        }
        group.wait()
        
        if (nil != err) {
            throw err!
        }
    }
    
    //MARK: - Ensure User
    
    /// Ensure that user is updated
    ///
    /// - Parameter forceSync: should fetch user or not. default `false`
    /// - Throws: OstError
    func ensureUser(forceSync: Bool = false) throws {
        if (forceSync
            ||  nil == self.currentUser
            ||  nil == self.currentUser!.tokenHolderAddress
            ||  nil == self.currentUser!.deviceManagerAddress) {
                try syncUser()
        }
    }
    
    /// Fetch user from server
    ///
    /// - Throws: OstError
    func syncUser() throws {
        var err: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIUser(userId: self.userId).getUser(onSuccess: { (ostUser) in
            group.leave()
        }, onFailure: { (error) in
            err = error
            group.leave()
        })
        group.wait()
        
        if (nil != err) {
            throw err!
        }
    }
    
    //MARK: - Ensure Token
    
    /// Ensure that token is preset
    ///
    /// - Throws: OstError
    func ensureToken() throws {
        if nil == self.currentUser {
            try ensureUser()
        }
        let tokenId: String = self.currentUser!.tokenId!
        let token: OstToken? = try OstToken.getById(tokenId)
        if nil == token?.auxiliaryChainId
            || nil == token?.decimals {
              try syncToken()
        }
    }
    
    /// Fetch token from server
    ///
    /// - Throws: OstError
    func syncToken() throws {
        var err: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        
        try OstAPITokens(userId: self.userId).getToken(onSuccess: { (token) in
            group.leave()
        }, onFailure: { (error) in
            err = error
            group.leave()
        })
        group.wait()
        
        if (nil != err) {
            throw err!
        }
    }
    
    //MARK: - Ensure Device
    
    /// Ensure that device is authorized
    ///
    /// - Throws: OstError
    func ensureDeviceAuthorized() throws {
        if nil == self.currentDevice {
            try ensureApiCommunication()
        }
        if !self.currentDevice!.isStatusAuthorized {
            try syncCurrentDevice()
            //Check Again
            if ( !self.currentDevice!.isStatusAuthorized ) {
                throw OstError("w_wev_eda_1", .deviceNotAuthorized);
            }
        }
    }
    
    //MARK: - Ensure Device Manager
    
    /// Ensure that device manager is persent
    ///
    /// - Throws: OstError
    func ensureDeviceManager() throws {
        if nil == self.currentUser {
            try ensureUser()
        }
        guard let deviceManagerAddress = self.currentUser!.deviceManagerAddress else {
            throw OstError("w_wev_edm_1", .userNotActivated);
        }
        guard let _ = try OstDeviceManager.getById(deviceManagerAddress) else {
            try syncDeviceManager()
            return
        }
    }
    
    /// Fetch device manager from server
    ///
    /// - Throws: OstError
    func syncDeviceManager() throws {
        _ = try fetchDeviceManager()
    }
    
    /// Fetch device manager from server
    ///
    /// - Returns: OstDeviceManager
    /// - Throws: OstError
    func fetchDeviceManager() throws -> OstDeviceManager {
        var err: OstError? = nil
        var ostDeviceManager: OstDeviceManager? = nil
        let group = DispatchGroup()
        group.enter()
        
        try OstAPIDeviceManager(userId: self.userId)
            .getDeviceManager(
                onSuccess: { (deviceManager) in
                    
                    ostDeviceManager = deviceManager
                    group.leave()
                    
            }, onFailure: { (error) in
                err = error
                group.leave()
            })
        group.wait()
        
        if (nil != err) {
            throw err!
        }
        
        return ostDeviceManager!
    }
    
   
}
