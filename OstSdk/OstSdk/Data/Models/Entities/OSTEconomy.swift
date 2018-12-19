//
//  OSTEconomyEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OSTEconomyEntity: OSTBaseEntity {
    init(jsonData: [String: Any])throws {
        super.init()
        if !validJSON(jsonData){
            throw EntityErrors.validationError("Invalid JSON passed.")
        }
        setJsonValues(jsonData)
    }
}

