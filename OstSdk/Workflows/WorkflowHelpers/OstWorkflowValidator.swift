//
//  OstWorkflowValidator.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 01/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstWorkflowValidator {
    private let userId: String
    private var currentUser: OstUser? {
        do {
            return try OstUser.getById(self.userId)
        }catch {
            return nil
        }
    }
    
    /// Initializer
    init(withUserId userId: String) throws {
        self.userId = userId
    }
    
    // MARK: - Device related validations
    
    /// Is device status authorizes
    ///
    /// - Returns: `true` if authorized otherwise `false`
    /// - Throws: OstError
    func isDeviceAuthorized() throws {
        let currentDevice = try self.getCurrentUserDevice()
        if !currentDevice.isStatusAuthorized {
            throw OstError("w_wfv_ida_1", OstErrorText.deviceNotAuthorized)
        }
    }
    
    // MARK: - User related validations
    
    /// Is user activated
    ///
    /// - Returns: `true` if user status is activated otherwise `false`
    /// - Throws: OstError
    func isUserActivated() throws {
        if (!self.currentUser!.isStatusActivated) {
            throw OstError("w_wfv_iua_1", OstErrorText.userNotActivated)
        }
    }
    
    /// Validate recovery owner address
    ///
    /// - Parameter pin: Pin string
    /// - Throws: Ost error
    func validateRecoveryOwnerAddress(_ recoveryOwnerAddress: String?) throws {
        if (nil == recoveryOwnerAddress) {
            throw OstError("w_wfv_vroa_1", OstErrorText.recoveryOwnerAddressNotFound)
        }
    }
    
    func isAPIKeyAvailable() throws {
        guard let apiAddress = OstKeyManager(userId: self.currentUser!.id).getAPIAddress() else {
            throw OstError("w_wfv_ialv_1", OstErrorText.apiAddressNotFound)
        }
        if (apiAddress.isEmpty) {
            throw OstError("w_wfv_ialv_2", OstErrorText.apiAddressNotFound)
        }
    }
    
    func isTokenAvailable() throws {
        guard let tokenId = self.currentUser!.tokenId else {
            throw OstError("w_wfv_ita_1", OstErrorText.tokenNotFound)
        }
        let _ = try OstToken.getById(tokenId)
    }
    
    
    private func getCurrentUserDevice() throws -> OstCurrentDevice{
        guard let currentDevice = self.currentUser!.getCurrentDevice() else {
            throw OstError("w_wv_gcud_1", .deviceNotFound);
        }
        return currentDevice
    }
}


