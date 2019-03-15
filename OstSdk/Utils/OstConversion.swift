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
    
    
    class func fiatToBt(ostToBtConversionFactor: String,
                        btDecimal: Int,
                        ostDecimal: Int,
                        fiatAmount: BigInt,
                        pricePoint: String) throws -> BigInt {
        
        let pricePointComponents = try OstConversion.getNumberComponents(pricePoint)
        let ost2BtComponents = try OstConversion.getNumberComponents(ostToBtConversionFactor)
        
        let exponent = btDecimal + ost2BtComponents.exponent - ostDecimal - pricePointComponents.exponent
        var denominator = pricePointComponents.number
        var numerator = fiatAmount * ost2BtComponents.number
        
        if exponent < 0 {
            denominator = denominator * BigInt(10).power(-(exponent))
        } else {
            numerator = numerator * BigInt(10).power(exponent)
        }
        
        let btAmount = numerator/denominator
        return btAmount
    }
}

