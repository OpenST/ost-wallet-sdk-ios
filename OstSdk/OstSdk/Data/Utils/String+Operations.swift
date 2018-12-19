//
//  String+Operations.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

extension String {
    var isAlphanumeric: Bool {
        return !isEmpty && range(of: "[^-a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
    func padLeft (totalWidth: Int, with: String) -> String {
        let toPad = totalWidth - self.count
        if toPad < 1 { return self }
        return "".padding(toLength: toPad, withPad: with, startingAt: 0) + self
    }
    
    func getFilteredHexString() -> String {
        var finalValue: String = self
        if (starts(with: "0x")) {
            let startIndex = index(self.startIndex, offsetBy: 2)
            finalValue = String(self[startIndex..<self.endIndex])
        }
        return finalValue
    }
}
