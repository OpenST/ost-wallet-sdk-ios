//
//  OstPerfrom+AddDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 20/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

extension OstPerform {
    func getDevice() throws {
        let deviceAddressToAdd = (self.payload!["device_to_add"])!
        
        let onSuccess: ((OstDevice) -> Void) = { ostDevice in
            if (ostDevice.isDeviceRegistered()) {
                self.authorizeDevice()
            }else {
                self.postError(OstError.actionFailed("Device is not registered. Please register device first."))
            }
        }
        
        try OstAPIDevice(userId: self.userId).getDevice(deviceAddress: deviceAddressToAdd, onSuccess: onSuccess) { (ostError) in
            self.postError(ostError)
        }
    }
    
    func authorizeDevice() {
        do {
            let deviceAddressToAdd = self.payload!["device_to_add"]
            let abiMethodName: String = "addOwnerWithThreshold"
            let encodedABIHex = try GnosisSafe().getAddOwnerWithThresholdExecutableData(abiMethodName: abiMethodName, ownerAddress: deviceAddressToAdd!, threshold: self.threshold)
            
            let deviceManagerNonce: Int = self.deviceManager!.nonce+1
            let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(to: self.deviceManager!.address!,
                                                                               value: "0",
                                                                               data: encodedABIHex,
                                                                               operation: "0",
                                                                               safeTxGas: "0",
                                                                               dataGas: "0",
                                                                               gasPrice: "0",
                                                                               gasToken: self.nullAddress,
                                                                               refundReceiver: self.nullAddress,
                                                                               nonce: OstUtils.toString(deviceManagerNonce)!)
            
            let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any], primaryType: typedDataInput["primaryType"] as! String, domain: typedDataInput["domain"] as! [String: String], message: typedDataInput["message"] as! [String: Any])
            let signingHash = try! eip712.getEIP712SignHash()
            
            try self.deviceManager!.updateNonce(deviceManagerNonce)
            
            let user: OstUser = try self.getUser()!
            let params: [String: Any] = ["data_defination":self.dataDefination!,
                                         "to": self.deviceManager!.address!,
                                         "value": "0",
                                         "calldata": encodedABIHex,
                                         "raw_calldata": ["method": abiMethodName,
                                                          "parameters": [deviceAddressToAdd!, "1"]],
                                         "operation": "0",
                                         "safe_tx_gas": "0",
                                         "data_gas": "0",
                                         "gas_price": "0",
                                         "gas_token": self.nullAddress,
                                         "refund_receiver": self.nullAddress,
                                         "signer": user.currentDevice!.address!,
                                         "signature": signingHash
            ]
            
            try OstAPIDevice(userId: self.userId).authorizeDevice(params: params, onSuccess: { (ostDevice) in
                self.postFlowCompleteForAddDevice(entity: ostDevice)
            }) { (error) in
                self.postError(error)
            }
        }catch let error {
            self.postError(error)
        }
    }
    
    func postFlowCompleteForAddDevice(entity: OstDevice) {
        Logger.log(message: "OstAddDevice flowComplete", parameterToPrint: entity.data)
        
        DispatchQueue.main.async {
            let contextEntity: OstContextEntity = OstContextEntity(type: .addDevice , entity: entity)
            self.delegate.flowComplete(contextEntity);
        }
    }
}
