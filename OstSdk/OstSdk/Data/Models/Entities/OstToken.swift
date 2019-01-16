//
//  OstToken.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstToken: OstBaseEntity {
    init(_ params: [String: Any]) throws {
        super.init()
        
        let isValidParams = try validate(params)
        if (!isValidParams) {
            throw OstError.actionFailed("Object creation failed")
        }
        
        setParams(params)
    }
}
