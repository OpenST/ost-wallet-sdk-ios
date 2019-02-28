
//
//  ABIHerlperBase.swift
//  OstSdk
//
//  Created by aniket ayachit on 25/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation


class ABIHerlperBase {
    
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
