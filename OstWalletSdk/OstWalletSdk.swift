/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc public class OstWalletSdk: NSObject {
    
    /// Initialize SDK
    ///
    /// - Parameter apiEndPoint: API end point
    /// - Throws: OstError
    @objc
    public class func initialize(apiEndPoint:String) throws {
        let sdkRef = OstSdkDatabase.sharedInstance
        sdkRef.runMigration()
        try setApiEndPoint(apiEndPoint:apiEndPoint);
        try OstConfig.loadConfig()
    }
    
    /// Get api end point
    ///
    /// - Returns: String
    @objc
    public class func getApiEndPoint() -> String {
        return OstAPIBase.baseURL
    }
    
    /// Get user biometric authentication status
    ///
    /// - Parameter userId: User Id
    /// - Returns: Biomertric status
    @objc 
    public class func isBiometricEnabled(userId: String) -> Bool {
        let keyManager = OstKeyManagerGateway.getOstKeyManager(userId: userId)
        return keyManager.isBiometricEnabled()
    }
    
    /// Get user entity for given user id
    ///
    /// - Parameter id: User id
    /// - Returns: User entity
    @objc
    public class func getUser(_ id: String) -> OstUser? {
        do {
            return try OstUser.getById(id)
        } catch {
            return nil
        }
    }
    
    /// Get token entity for given token id
    ///
    /// - Parameter id: Token id
    /// - Returns: Token entity
    @objc
    public class func getToken( _ id: String) -> OstToken? {
        do {
            return try OstToken.getById(id)
        } catch {
            return nil
        }
    }
    
    /// Validate and set api end point
    ///
    /// - Parameter apiEndPoint: API end point
    /// - Throws: OstError
    fileprivate class func setApiEndPoint(apiEndPoint: String) throws {
        let endPointSplits = apiEndPoint.split(separator: "/");
        if ( endPointSplits.count < 4 ) {
            throw OstError("ost_sdk_vpep_1", .invalidApiEndPoint);
        }
        //Unlike javascript, where we read index 4 for version, we have to read index 3 in swift.
        //Reason: the splits do not contain empty string. http://axy produces 2 splits instead of 3.
        let providedApiVersion = endPointSplits[3].lowercased();
        let expectedApiVersion = ("v" + OstConstants.OST_API_VERSION).lowercased();
        if ( providedApiVersion.compare(expectedApiVersion) != .orderedSame ) {
            throw OstError("ost_sdk_vpep_2", .invalidApiEndPoint);
        }
        
        var finalApiEndpoint = apiEndPoint.lowercased();
        
        //Let's be tolerant for the extra '/' 
        if ( finalApiEndpoint.hasSuffix("/") ) {
            finalApiEndpoint = String(finalApiEndpoint.dropLast());
        }
        
        // Logger.log(message: "finalApiEndpoint", parameterToPrint: finalApiEndpoint);
        OstAPIBase.setAPIEndpoint(finalApiEndpoint);
    }
    
    /// Get session addresses from keymanager and fetch session data from db.
    @objc
    public class func getActiveSessions(userId: String, spendingLimit: String?) -> [OstSession] {
        var minSpendingLimit:BigInt = BigInt(0);
        if ( nil != spendingLimit ) {
            let convertedVal = BigInt(spendingLimit!);
            if ( nil != convertedVal ) {
                minSpendingLimit = convertedVal!;
            }
        }
        return OstSession.getActiveSessions(userId: userId, minSpendingLimit: minSpendingLimit);
    }
    
}
