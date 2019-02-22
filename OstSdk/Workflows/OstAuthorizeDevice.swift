//
//  OstAuthorizeDevice.swift
//  
//
//  Created by aniket ayachit on 21/02/19.
//

import Foundation

class OstAuthorizeDevice {
    let threshold = 1
    let workflowTransactionCountForPolling = 1
    let abiMethodName = "addOwnerWithThreshold"
    let nullAddress = "0x0000000000000000000000000000000000000000"
    let dataDefination = OstPerform.DataDefination.AUTHORIZE_DEVICE.rawValue
    
    var deviceManager: OstDeviceManager? = nil
    
    let userId: String
    let deviceAddressToAdd: String
    let generateSignatureCallback: ((String) -> (String?, String?))
    
    let onSuccess: ((OstDevice)-> Void)
    let onFailure: ((OstError) -> Void)
    
    init (userId: String, deviceAddressToAdd: String,
          generateSignatureCallback: @escaping ((String) -> (String?, String?)),
          onSuccess: @escaping ((OstDevice)-> Void),
          onFailure: @escaping ((OstError) -> Void)) {
        
        self.userId = userId
        self.deviceAddressToAdd = deviceAddressToAdd
        self.generateSignatureCallback = generateSignatureCallback
        
        self.onSuccess = onSuccess
        self.onFailure = onFailure
    }
    
    func perform() {
        do {
            try self.getDevice()
        }catch let error {
            self.onFailure(error as! OstError)
        }
    }
    
    func getDevice() throws {
        let onSuccess: ((OstDevice) -> Void) = { ostDevice in
            if (ostDevice.isDeviceRegistered()) {
                do {
                    try self.fetchDeviceManager()
                }catch let error{
                    self.onFailure(error as! OstError)
                }
            }else {
                self.onFailure(OstError.actionFailed("Device is not registered."))
            }
        }
        
        try OstAPIDevice(userId: self.userId).getDevice(deviceAddress: self.deviceAddressToAdd, onSuccess: onSuccess) { (ostError) in
            self.onFailure(ostError)
        }
    }
    
    func fetchDeviceManager() throws {
        try OstAPIDeviceManager(userId: self.userId).getDeviceManager(onSuccess: { (ostDeviceManager) in
            self.deviceManager = ostDeviceManager
            self.authorizeDevice()
        }) { (ostError) in
             self.onFailure(ostError)
        }
    }
    
    func authorizeDevice() {
        do {
            let encodedABIHex = try GnosisSafe().getAddOwnerWithThresholdExecutableData(abiMethodName: abiMethodName,
                                                                                        ownerAddress: self.deviceAddressToAdd,
                                                                                        threshold: OstUtils.toString(self.threshold)!)
            
            let deviceManagerNonce: Int = self.deviceManager!.nonce
            let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(verifyingContract: self.deviceManager!.address!,
                                                                               to: self.deviceManager!.address!,
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
            
            let (signature, signerAddress) = self.generateSignatureCallback(signingHash)
            
            if (nil == signature || signature!.isEmpty) {
                throw OstError.actionFailed("signature is not generated")
            }
            
            if (nil == signerAddress || signerAddress!.isEmpty) {
                throw OstError.actionFailed("signer address is not generated")
            }
            
            try self.deviceManager!.updateNonce(deviceManagerNonce+1)
            
            let params: [String: Any] = ["data_defination":self.dataDefination,
                                         "to": self.deviceManager!.address!,
                                         "value": "0",
                                         "calldata": encodedABIHex,
                                         "raw_calldata": ["method": self.abiMethodName,
                                                          "parameters": [deviceAddressToAdd, "1"]],
                                         "operation": "0",
                                         "safe_tx_gas": "0",
                                         "data_gas": "0",
                                         "gas_price": "0",
                                         "nonce": OstUtils.toString(deviceManagerNonce)!,
                                         "gas_token": self.nullAddress,
                                         "refund_receiver": self.nullAddress,
                                         "signers": [signerAddress],
                                         "signatures": signature!
            ]
            
            try OstAPIDevice(userId: self.userId).authorizeDevice(params: params, onSuccess: { (ostDevice) in
                self.onSuccess(ostDevice)
            }) { (error) in
                self.onFailure(error)
            }
        }catch let error {
            onFailure(error as! OstError)
        }
    }
    
}
