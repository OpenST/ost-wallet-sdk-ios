//
//  TypedDataForResetPin.swift
//  OstSdk
//
//  Created by Deepesh Kumar Nath on 01/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class TypedDataForResetPin {
    private static let RESET_RECOVERY_OWNER_STRUCTURE = "ResetRecoveryOwnerStruct"
    
    class func getResetPinTypedData(verifyingContract: String,
                                    oldRecoveryOwner: String,
                                    newRecoveryOwner: String) -> [String: Any] {
        let typedDataInput: [String: Any] = [
            "types": [
                "EIP712Domain": [[ "name": "verifyingContract", "type": "address" ]],
                TypedDataForResetPin.RESET_RECOVERY_OWNER_STRUCTURE: [
                    [ "name": "oldRecoveryOwner", "type": "address" ],
                    [ "name": "newRecoveryOwner", "type": "address" ]
                ]
            ],
            "primaryType": TypedDataForResetPin.RESET_RECOVERY_OWNER_STRUCTURE,
            "domain": [
                "verifyingContract": verifyingContract
            ],
            "message": [
                "oldRecoveryOwner": oldRecoveryOwner,
                "newRecoveryOwner": newRecoveryOwner
            ]
        ]
        
        return typedDataInput
    }
}


