//
//  OstSdkSync.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSdkSync {

    enum SyncEntites: Int {
        case User, Devices, Token, DeviceManager, Sessions
    }
    
    var userId: String
    var tokenId: String
    var syncEntites: [SyncEntites]
    
    init(userId: String, tokenId: String, syncEntites: SyncEntites...) {
        self.userId = userId
        self.tokenId = tokenId
        self.syncEntites = syncEntites
    }    
    
    func syncUser(success:@escaping ((OstUser) -> Void), failuar:@escaping ((OstError) -> Void)) throws {
        try OstAPIUser(userId: userId).getUser(success: success, failuar: failuar)
    }
    
    func syncToken(success:@escaping ((OstToken) -> Void), failuar:@escaping ((OstError) -> Void)) throws {
        try OstAPITokens(userId: userId, tokenId: tokenId).getToken(success: success, failuar: failuar)
    }
    
}
