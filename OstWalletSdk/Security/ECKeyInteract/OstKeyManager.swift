/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstKeyManager {
    
    private let userId: String
    private let keyManagareDelegate: OstKeyManagerDelegate
    
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - keyManagareDelegate: OstKeyManagerDelegate
    init(userId: String,
         keyManagareDelegate: OstKeyManagerDelegate) {
        
        self.userId = userId
        self.keyManagareDelegate = keyManagareDelegate
    }
    
    /// Get API address
    ///
    /// - Returns: API Address
    func getAPIAddress() -> String? {
        return self.keyManagareDelegate.getAPIAddress()
    }
    
    /// Create device key
    ///
    /// - Returns: Device address
    /// - Throws: OstError
    func createDeviceKey() throws -> String  {
        return try self.keyManagareDelegate.createDeviceKey()
    }
    
    /// Create API key
    ///
    /// - Returns: API key address
    /// - Throws: OstError
    func createAPIKey() throws -> String  {
        return try self.keyManagareDelegate.createAPIKey()
    }
    
    /// Get Device mnemonics
    ///
    /// - Returns: Mnemonics array
    /// - Throws: OstError
    func getDeviceMnemonics() throws -> [String]? {
        return try self.keyManagareDelegate.getDeviceMnemonics()
    }
    
    /// Delegate session keys
    ///
    /// - Parameter sessionAddress: Session Address
    /// - Throws: OstError
    func deleteSessionKey(sessionAddress: String) throws {
        try self.keyManagareDelegate.deleteSessionKey(sessionAddress: sessionAddress)
    }
    
    /// Get Device address
    ///
    /// - Returns: Device address
    func getDeviceAddress() -> String?  {
        return self.keyManagareDelegate.getDeviceAddress()
    }
    
    /// Create session keys
    ///
    /// - Returns: Session Address
    /// - Throws: OstError
    func createSessionKey() throws -> String {
        return try self.keyManagareDelegate.createSessionKey()
    }
    
    /// Get all session addresses
    ///
    /// - Returns: Session addresses array
    /// - Throws: OstError
    func getSessions() throws -> [String]  {
        return try self.keyManagareDelegate.getSessions()
    }
    
    /// Clear user device info
    ///
    /// - Throws: OstError
    func clearUserDeviceInfo() throws {
        try self.keyManagareDelegate.clearUserDeviceInfo()
    }
    
    /// Delete all sessions
    func deleteAllSessions() {
        self.keyManagareDelegate.deleteAllSessions()
    }
    
    /// Sign with Session Key
    ///
    /// - Parameters:
    ///   - tx: Data to Sign
    ///   - address: Session address
    /// - Returns: Signature
    /// - Throws: OstError
    func signWithSessionKey(_ tx: String,
                            withAddress address: String) throws -> String {
        
        return try self.keyManagareDelegate.signWithSessionKey(tx,
                                                               withAddress:address)
    }
    
    /// Get user biometric preference
    ///
    /// - Returns: true if biometric preference allowed, default false
    func isBiometricEnabled() -> Bool {
        return self.keyManagareDelegate.isBiometricEnabled()
    }
}
