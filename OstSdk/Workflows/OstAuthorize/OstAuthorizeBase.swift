//
//  OstAuthorize.swift
//  OstSdk
//
//  Created by aniket ayachit on 22/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstAuthorizeBase {
    let threshold = 1
    let workflowTransactionCountForPolling = 1
    let nullAddress = "0x0000000000000000000000000000000000000000"
    let dataDefination = OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue
    
    var deviceManager: OstDeviceManager? = nil
    
    let userId: String
    let addressToAdd: String
    let generateSignatureCallback: ((String) -> (String?, String?))
    
    let onFailure: ((OstError) -> Void)
    
    init (userId: String,
          addressToAdd: String,
          generateSignatureCallback: @escaping ((String) -> (String?, String?)),
          onFailure: @escaping ((OstError) -> Void)) {
        
        self.userId = userId
        self.addressToAdd = addressToAdd
        self.generateSignatureCallback = generateSignatureCallback

        self.onFailure = onFailure
    }
    
    func perform() {
        do {
            try self.fetchDeviceManager()
        }catch let error {
            self.onFailure(error as! OstError)
        }
    }
    
    func fetchDeviceManager() throws {
        try OstAPIDeviceManager(userId: self.userId).getDeviceManager(onSuccess: { (ostDeviceManager) in
            self.deviceManager = ostDeviceManager
            self.authorize()
        }) { (ostError) in
            self.onFailure(ostError)
        }
    }
    
    func getEncodedABI() throws -> String {
        fatalError("getEncodedABI is not override.")
    }
    
    func getRawCallData() -> String {
        fatalError("getRawCallData is not override.")
    }
    
    func getABIName() -> String {
        fatalError("getABIName is not override.")
    }
    
    func apiRequestForAuthorize(params: [String: Any]) throws {
        fatalError("apiRequestForAuthorize is not override.")
    }
    
    func getToForTypedData() -> String? {
        fatalError("getToForTypeData is not override.")
    }
    
    func authorize() {
        do {
            let encodedABIHex = try getEncodedABI()
            
            let deviceManagerNonce: Int = self.deviceManager!.nonce
            
            guard let toForTypedData = getToForTypedData() else {
                throw OstError("w_a_ab_a_1", .toAddressNotFound)
            }
            
            let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(verifyingContract: self.deviceManager!.address!,
                                                                               to: toForTypedData,
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
                throw OstError("q_a_ab_a_2", .signatureGenerationFailed)
            }
            
            if (nil == signerAddress || signerAddress!.isEmpty) {
                throw OstError("q_a_ab_a_2", .signerAddressNotFound)
            }
            
            try self.deviceManager!.incrementNonce()
            
            let rawCallData: String = getRawCallData()
            
            let params: [String: Any] = ["data_defination":self.dataDefination,
                                         "to": toForTypedData,
                                         "value": "0",
                                         "calldata": encodedABIHex,
                                         "raw_calldata": rawCallData,
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
            
            try apiRequestForAuthorize(params: params)
        }catch let error {
            onFailure(error as! OstError)
        }
    }
}
