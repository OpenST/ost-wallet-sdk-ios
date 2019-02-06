//
//  OstMockUser.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 06/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
@testable import OstSdk

class OstMockUser: OstUser {
    override init(_ params: [String : Any]) throws {
        try super.init(params)
        
        OstUser.currentDevice = try! OstCurrentDevice(["user_id": OstMockAPISigner.userId,
                                                       "address": "0x60A20Cdf6a21a73Fb89475221D252865C695e302",
                                                       "personal_sign_address": "0xf65c7a49981db56AED34beA4617E32e326ACf977",
                                                       "device_name": "iPhone X",
                                                       "device_uuid": "34613278-fwib3jkds-3r2142134",
                                                       "updated_timestamp": "1549294289"])
        
        OstUser.tokenId = "58"
    }
    
    
}
