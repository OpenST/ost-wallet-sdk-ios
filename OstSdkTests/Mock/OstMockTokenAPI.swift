//
//  OstMockTokenAPI.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 06/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
@testable import OstSdk

class OstMockTokenAPI: OstTokensAPI {
    override init() {
        super.init()
        _ = try! OstMockUser(["id":OstMockAPISigner.userId])
    }
    
    override func sign(_ params: inout [String: Any?]) throws {
        let (signature, _) =  try OstMockAPISigner(userId: OstUser.currentDevice!.user_id!).sign(resource: getResource, params: params)
        params["signature"] = signature
    }
}
