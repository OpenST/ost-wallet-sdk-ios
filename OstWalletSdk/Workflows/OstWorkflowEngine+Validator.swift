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
    func isValidNumber(input: String) throws{
        if input.isEmpty {
            throw OstError("w_wfv_ivn_1", .invalidNumber)
        }
        guard let _ = BigInt(input) else {
            throw OstError("w_wfv_ivn_2", .invalidNumber)
        }
    }
    
    // MARK: - Device related validations
    
    /// Is device status authorizes
    ///
    /// - Throws: OstError
    func isDeviceAuthorized() throws {
        let currentDevice = try self.getCurrentUserDevice()
        if !currentDevice.isStatusAuthorized {
            throw OstError("w_wfv_ida_1", OstErrorText.deviceNotAuthorized)
        }
    }
    
    /// Is device status registered.
    ///
    /// - Throws: OstError
    func isDeviceRegistered() throws {
        let currentDevice = try self.getCurrentUserDevice()
        if !currentDevice.isStatusRegistered {
            throw OstError("w_wfv_idr_1", OstErrorText.deviceNotRegistered)
        }
    }
    
    // MARK: - User related validations
    
    /// Is user activated
    ///
    /// - Throws: OstError
    func isUserActivated() throws {
        if (!self.currentUser!.isStatusActivated) {
            throw OstError("w_wfv_iua_1", OstErrorText.userNotActivated)
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
            throw OstError("w_wfv_vroa_1", OstErrorText.recoveryOwnerAddressNotFound)
        }
    }
    
    /// Check whether api key is available or not
    ///
    /// - Throws: OstError
    func isAPIKeyAvailable() throws {
        guard let apiAddress = OstKeyManager(userId: self.currentUser!.id).getAPIAddress() else {
            throw OstError("w_wfv_ialv_1", OstErrorText.apiAddressNotFound)
        }
        if (apiAddress.isEmpty) {
            throw OstError("w_wfv_ialv_2", OstErrorText.apiAddressNotFound)
        }
    }
    
    /// Check whether token entity is present or not
    ///
    /// - Throws: OstError
    func isTokenAvailable() throws {
        guard let tokenId = self.currentUser!.tokenId else {
            throw OstError("w_wfv_ita_1", OstErrorText.tokenNotFound)
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
}
