//
//  Decimal+Extension.swift
//  OstSdk
//
//  Created by aniket ayachit on 07/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

extension Decimal {
    var significantFractionalDecimalDigits: Int {
        return max(-exponent, 0)
    }
    
    var formattedString: String {
        return Formatter.stringFormatters.string(for: self) ?? ""
    }
    
}

extension Formatter {
    static let stringFormatters: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        return formatter
    }()
}
