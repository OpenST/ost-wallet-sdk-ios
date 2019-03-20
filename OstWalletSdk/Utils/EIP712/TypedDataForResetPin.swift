/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

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


