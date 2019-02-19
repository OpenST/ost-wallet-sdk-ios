//
//  Date+Timestamp.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

extension Date {
    static func negativeTimestamp() -> Int {
        return -timestamp()
    }
    
    static func timestamp() -> Int {
        return Int(Date().timeIntervalSince1970)
    }
}
