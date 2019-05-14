/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import BigInt

class OstSolidityValue {
 
    static func getSolidtyValue(_ string: String, for type: SolidityType) throws -> ABIEncodable {
        let stringType = type.stringValue
        
        if (stringType.starts(with: "uint") || stringType.starts(with: "int")) {
            if let bigInt = BigInt(string) {
                return bigInt
            }
            throw OstError("u_sv_gsv_1", .invalidSolidityTypeInt)
            
        } else if (stringType == "address") {
            if let ethAddress = EthereumAddress(hexString: string) {
               return ethAddress
            }
            throw OstError("u_sv_gsv_1", .invalidSolidityTypeAddress)
            
        } else if (stringType.starts(with: "bytes")) {
            return Data(hex: string)
            
        } else if (stringType == "string") {
            return string
            
        }
        
        return ""
    }
}
