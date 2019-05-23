//
//  String+Extension.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 01/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstWalletSdk

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
    
    
    func toDisplayTxValue() -> String {
        var formattedDecimal: String = "00"
        
        let values = self.components(separatedBy: ".")
        if values.count == 2 {
            let decimalVal: String = values[1]
        
            let decimals = decimalVal.substringTill(2)
            if !decimals.isEmpty {
                formattedDecimal = decimals
            }
        }
        return "\(values[0]).\(formattedDecimal)"
    }
}

extension String {
    var toRedableFormat: String {
        let economyDecimals = CurrentEconomy.getInstance.getEconomyDecimals()
        
        if economyDecimals == 6 {
            return OstUtils.fromMicro(self)
        }
        else if economyDecimals == 18 {
            return OstUtils.fromAtto(self)
        }
        
        return ""
    }
    
    func toSmallestUnit(isUSDTx: Bool) -> String {
        let economyDecimals = CurrentEconomy.getInstance.getEconomyDecimals()
        if economyDecimals == 6 {
            if isUSDTx {
                return self + "0000"
            }else {
                return self + "000000"
            }
        }
        else if economyDecimals == 18 {
            if isUSDTx {
                return self + "0000000000000000"
            }else {
                return self + "000000000000000000"
            }
        }
        
        return self
    }
}
