//
//  OstSdk.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstSdk {
    
    /// Initialize SDK
    ///
    /// - Parameter apiEndPoint: API end point
    /// - Throws: OstError
    public class func initialize(apiEndPoint:String) throws {
        
        let sdkRef = OstSdkDatabase.sharedInstance
        sdkRef.runMigration()
        try setApiEndPoint(apiEndPoint:apiEndPoint);
        try OstConfig.loadConfig()
    }
    
    /// Get api end point
    ///
    /// - Returns: String
    public class func getApiEndPoint() -> String {
        return OstAPIBase.baseURL
    }
    
    /// Get user entity for given user id
    ///
    /// - Parameter id: User id
    /// - Returns: User entity
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
    public class func getTokne( _ id: String) -> OstToken? {
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
}
