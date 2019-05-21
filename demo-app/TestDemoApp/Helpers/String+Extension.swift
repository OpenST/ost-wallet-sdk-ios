//
//  String+Extension.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 01/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

extension String {
    
    public  func substringTill(_ offset: Int) -> String {
        if self.count < offset {
            return self
        }
        let endIndex = index(self.startIndex, offsetBy: offset)
        let substingVal = self[self.startIndex..<endIndex]
        return String(substingVal)
    }
    
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
    
    func character(at position: Int) -> Character? {
        guard !self.isEmpty, position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
    
    func displayTransactionValue() -> String {
        let values = self.components(separatedBy: ".")
        if values.count == 2 {
            let decimalVal: String = values[1]
        
            let formattedDecimal = decimalVal.substringTill(2)
            if !formattedDecimal.isEmpty {
                return "\(values[0]).\(formattedDecimal)"
            }
        }
        return values[0]
    }
}
