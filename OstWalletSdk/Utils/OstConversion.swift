/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import BigInt

class OstConversion {
    
    class func getNumberComponents(_ number: String) throws -> OstUtils.NumberComponents {
        return try OstUtils.getNumberComponents( number );
    }
    
    
    class func fiatToBt(ostToBtConversionFactor: String,
                        btDecimal: Int,
                        fiatDecimal: Int,
                        fiatAmount: BigInt,
                        pricePoint: String) throws -> BigInt {
        
        let pricePointComponents = try OstConversion.getNumberComponents(pricePoint)
        let ost2BtComponents = try OstConversion.getNumberComponents(ostToBtConversionFactor)
        
        let exponent = btDecimal + ost2BtComponents.exponent - fiatDecimal - pricePointComponents.exponent
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

