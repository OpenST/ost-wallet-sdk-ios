//
//  TypedDataForRecovery.swift
//  OstSdk
//
//  Created by aniket ayachit on 01/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class TypedDataForRecovery {
    private static let INITIATE_RECOVERY_STRUCT = "InitiateRecoveryStruct"
    
    class func getInitiateRecoveryTypedData(verifyingContract: String,
                                            prevOwner: String,
                                            oldOwner: String,
                                            newOwner: String) -> [String: Any] {
        
        return TypedDataForRecovery.getTypedDataFor(primaryType: INITIATE_RECOVERY_STRUCT,
                                                    verifyingContract: verifyingContract,
                                                    prevOwner: prevOwner,
                                                    oldOwner: oldOwner,
                                                    newOwner: newOwner)
        
    }
    
    private class func getTypedDataFor(primaryType: String,
                                       verifyingContract: String,
                                       prevOwner: String,
                                       oldOwner: String,
                                       newOwner: String) -> [String: Any] {
        let typedDataInput: [String: Any] = [
            "types": [
                "EIP712Domain": [[ "name": "verifyingContract", "type": "address" ]],
                primaryType: [
                    [ "name": "prevOwner", "type": "address" ],
                    [ "name": "oldOwner", "type": "address" ],
                    [ "name": "newOwner", "type": "address" ]
                ]
            ],
            "primaryType": primaryType,
            "domain": [
                "verifyingContract": verifyingContract
            ],
            "message": [
                "prevOwner": prevOwner,
                "oldOwner": oldOwner,
                "newOwner": newOwner
            ]
        ]
        return typedDataInput
    }
}
