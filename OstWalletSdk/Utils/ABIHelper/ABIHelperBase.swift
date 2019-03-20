/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation


class ABIHelperBase {
    
    init() {
        
    }
    
    func getABI(_ abiName: String, forMethod methodName: String) throws -> ABIObject? {
        let content = try OstBundle.getContentOf(file: abiName, fileExtension: "json")
        
        let contractJsonABI = content.data(using: .utf8)!
        let decoder = JSONDecoder()
        let abiArray = try decoder.decode([ABIObject].self, from: contractJsonABI)
        
        for abi in abiArray {
            if let abiName = abi.name {
                if (abiName == methodName) {
                    return abi
                }
            }
        }
        return nil
    }
}
