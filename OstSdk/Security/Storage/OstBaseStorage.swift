//
//  OstBaseStorage.swift
//  OstSdk
//
//  Created by aniket ayachit on 01/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstBaseStorage {
    init() { }
    
    func getAccessControl() -> SecAccessControl {
        let access =
            SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                            .privateKeyUsage,
                                            nil)!
        
        return access
    }
}
