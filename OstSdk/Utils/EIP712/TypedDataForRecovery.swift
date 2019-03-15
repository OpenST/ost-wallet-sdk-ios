/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class TypedDataForRecovery {
    private static let INITIATE_RECOVERY_STRUCT = "InitiateRecoveryStruct"
    private static let ABORT_RECOVERY_STRUCT = "AbortRecoveryStruct"
    
    /// Initiate recovery 
    ///
    /// - Parameters:
    ///   - verifyingContract: Recovery address of user
    ///   - prevOwner: Linked address of device to recover
    ///   - oldOwner: Device address of device to recover
    ///   - newOwner: Device address of current device
    /// - Returns: TypedData dictionary
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
    
    /// Abort recover device
    ///
    /// - Parameters:
    ///   - verifyingContract: Recovery address of user
    ///   - prevOwner: Linked address of device to abort
    ///   - oldOwner: Device address of device to abort
    ///   - newOwner: Device address of current device
    /// - Returns: TypedData dictionary
    class func getAbortRecoveryTypedData(verifyingContract: String,
                                            prevOwner: String,
                                            oldOwner: String,
                                            newOwner: String) -> [String: Any] {
        
        return TypedDataForRecovery.getTypedDataFor(primaryType: ABORT_RECOVERY_STRUCT,
                                                    verifyingContract: verifyingContract,
                                                    prevOwner: prevOwner,
                                                    oldOwner: oldOwner,
                                                    newOwner: newOwner)
        
    }
    
    /// Get typed data
    ///
    /// - Parameters:
    ///   - primaryType: Type of data input
    ///   - verifyingContract: verifying contract address
    ///   - prevOwner: previous owner
    ///   - oldOwner: old owner address
    ///   - newOwner: new owner address
    /// - Returns: TypedData of dictinary
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
