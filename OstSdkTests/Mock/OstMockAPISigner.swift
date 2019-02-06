//
//  OstMockAPISigner.swift
//  OstSdkTests
//
//  Created by aniket ayachit on 06/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
@testable import OstSdk

class OstMockAPISigner: OstAPISigner {
    static let userId = "bcffc567-2881-4610-aa86-fa89f37bc197"
    static let apiSigner: ApiSigner = ApiSigner(userId: OstMockAPISigner.userId,
                                                APIKey: "0x6edc3804eb9f70b26731447b4e43955c5532f2195a6fe77cbed287dbd3c762ce")
    
    override init(userId: String) {
        super.init(userId: userId)
    }
    
    override func getAPISigner() -> ApiSigner? {
        return OstMockAPISigner.apiSigner
    }
}
