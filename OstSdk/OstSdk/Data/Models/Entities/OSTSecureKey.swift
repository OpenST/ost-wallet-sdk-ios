//
//  OSTSecureKeyEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

class OSTSecureKey: OSTBaseEntity {
    private(set) var key: String
    private(set) var secData: Data
    
    init(data: Data, forKey key: String) {
        self.key = key
        self.secData = data
    }
}
