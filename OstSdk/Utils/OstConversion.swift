//
//  OstConversion.swift
//  OstSdk
//
//  Created by aniket ayachit on 12/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import BigInt

class OstConversion {
    
    static let WEI_EXPONENT = 18
    typealias NumberComponents = (number: BigInt, exponent: Int)
    
    class func getNumberComponents(_ number: String) throws -> NumberComponents {
        let components = number.split(separator: ".")
        var exponent: Int
        var afterDecimalString: Substring = ""
        
        if components.count == 1 {
            exponent = 0
        }else if components.count == 2 {
            afterDecimalString = components[1]
            while (afterDecimalString.hasSuffix("0") && afterDecimalString.count>0) {
                afterDecimalString = afterDecimalString.dropLast()
            }
            exponent = afterDecimalString.count
        }else {
            throw OstError("u_c_gnc_1", OstErrorText.invalidAmount)
        }
        
        guard let numberComponent  = BigInt("\( components[0])\(afterDecimalString)") else {
            throw OstError("u_c_gnc_2", OstErrorText.invalidAmount)
        }
        
        return (numberComponent, -(exponent))
    }
    
    
    class func fiatToBt(btToOstConversionFactor: String,
                        btDecimal: Int,
                        ostDecimal: Int,
                        fiatAmount: BigInt,
                        pricePoint: String) throws -> BigInt {
        
        let pricePointComponents = try OstConversion.getNumberComponents(pricePoint)
        let bt2OstComponents = try OstConversion.getNumberComponents(btToOstConversionFactor)
        
        
        let exponent = btDecimal - ostDecimal - pricePointComponents.exponent - bt2OstComponents.exponent
        var denominator = pricePointComponents.number * bt2OstComponents.number
        var btAmount = BigInt(0)
        if exponent<0 {
            denominator = denominator * BigInt(10).power(-(exponent))
            btAmount = fiatAmount/denominator
        } else {
          btAmount = fiatAmount * BigInt(10).power(exponent)
          btAmount = btAmount/denominator
        }
       return btAmount
    }
}

