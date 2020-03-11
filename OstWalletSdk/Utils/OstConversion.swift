/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import BigInt

public class OstConversion {
    
    class func getNumberComponents(_ number: String) throws -> OstUtils.NumberComponents {
        return try OstUtils.getNumberComponents( number );
    }
    
    public class func fiatToBt(ostToBtConversionFactor: String,
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
	
	public class func toLowestUnit(_ number: String, tokenId: String) throws -> String {
		guard let token = try OstToken.getById(tokenId) else {
			throw OstError(internalCode: "u_oc_thu_1", errorCode: OstErrorCodes.OstErrorCode.invalidTokenId)
		}
		let decimals = token.decimals ?? 1
		
		return OstUtils.convertNum(amount: number, exponent: decimals)
	}
	
	public class func toHighestUnit(_ number: String, tokenId: String) throws -> String {
		guard let token = try OstToken.getById(tokenId) else {
			throw OstError(internalCode: "u_oc_thu_1", errorCode: OstErrorCodes.OstErrorCode.invalidTokenId)
		}
		let decimals = token.decimals ?? 1
		
		return OstUtils.convertNum(amount: number, exponent: -1 * decimals)
	}
}

