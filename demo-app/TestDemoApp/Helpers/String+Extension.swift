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
        let commonStandardVal = self.replacingOccurrences(of: ",", with: ".")
        let values = commonStandardVal.components(separatedBy: ".")
        if values.count == 2 {
            let decimalVal: String = values[1]
        
            let decimals = decimalVal.substringTill(2)
            if !decimals.isEmpty {
                formattedDecimal = decimals
            }
        }
        
        let intPart: String = (values[0] as String).isEmpty ? "0" : values[0]
        return "\(intPart).\(formattedDecimal)"
    }
    
    func toRoundUpTxValue() -> String {
        var formattedDecimal: String = "00"
        let commonStandardVal = self.replacingOccurrences(of: ",", with: ".")
        let values = commonStandardVal.components(separatedBy: ".")
        if values.count == 2 {
            let decimalVal: String = values[1]
            
            let decimals = decimalVal.substringTill(3)
            if !decimals.isEmpty {
                formattedDecimal = decimals
            }
        }
        
        let intPart: String = (values[0] as String).isEmpty ? "0" : values[0]
        let doubleVal = Double("\(intPart).\(formattedDecimal)")!
        return String(format: "%.2f", doubleVal)
    }
}

extension String {
    func toRedableFormat(isUSDTx: Bool = false) -> String {
        let economyDecimals = CurrentEconomy.getInstance.getEconomyDecimals()
        
        if economyDecimals == 6 {
            if isUSDTx {
                return OstUtils.fromAtto(self)
            }
            return OstUtils.fromMicro(self)
        }
        else if economyDecimals == 18 {
            return OstUtils.fromAtto(self)
        }
        
        return ""
    }
    
    func toSmallestUnit(isUSDTx: Bool) -> String {
        
        if isUSDTx {
            return OstUtils.toAtto(self)
        }
        
        let economyDecimals = CurrentEconomy.getInstance.getEconomyDecimals()
        if economyDecimals == 6 {
            return OstUtils.toMicro(self)
        }
        else if economyDecimals == 18 {
            return OstUtils.toAtto(self)
        }
        
        return self
    }
}
