//
//  OstSdk.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstSdk {

    public class func initialize() {
        let sdkRef = OstSdkDatabase.sharedInstance
        sdkRef.runMigration()
    }
    
    public class func parse(_ apiResponse: [String: Any?]) throws {
        try OstAPIHelper.storeApiResponse(apiResponse)
    }

    public class func getUser(_ id: String) throws -> OstUser? {
        return try OstUser.getById(id)
    }
}
