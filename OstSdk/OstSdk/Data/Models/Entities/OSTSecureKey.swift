//
//  OSTSecureKeyEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OSTSecureKey: OSTBaseEntity {
   
    public init(jsonPram: [String: Any])throws {
        super.init()
        if !validJSON(jsonPram){
            throw EntityErrors.validationError("Invalid JSON passed.")
        }
        setJsonValues(jsonPram)
    }
}
