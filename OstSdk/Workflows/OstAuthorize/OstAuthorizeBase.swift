/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstAuthorizeBase {
    private let ostAuthorizeRetryQueue = DispatchQueue(label: "OstAuthorizeRetryQueue", qos: .background)
    private let nullAddress = "0x0000000000000000000000000000000000000000"
    private let generateSignatureCallback: ((String) -> (String?, String?))
    
    var deviceManager: OstDeviceManager? = nil
    let userId: String
    let addressToAdd: String
    let onFailure: ((OstError) -> Void)

    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - addressToAdd: Address to add
    ///   - generateSignatureCallback: Callback to get signature
    ///   - onFailure: Callback when flow failed.
    init (userId: String,
          addressToAdd: String,
          generateSignatureCallback: @escaping ((String) -> (String?, String?)),
          onFailure: @escaping ((OstError) -> Void)) {
        
        self.userId = userId
        self.addressToAdd = addressToAdd
        self.generateSignatureCallback = generateSignatureCallback
        
        self.onFailure = onFailure
    }
    
    /// Perform authorization
    func perform() {
        if (nil == self.deviceManager) {
            do {
                guard let user = try OstUser.getById(self.userId) else {
                    throw OstError("w_a_ab_p_1", .userNotFound)
                }
                self.deviceManager = try OstDeviceManager.getById(user.deviceManagerAddress!)
                if (nil == deviceManager) {
                    try self.fetchDeviceManager()
                }
            } catch let error {
                self.onFailure(error as! OstError)
            }
        }
        self.authorize()
    }
    
    /// Get device manager from server
    ///
    /// - Throws: OstError
    func fetchDeviceManager() throws {
        var error: OstError? = nil
        let group: DispatchGroup = DispatchGroup()
        group.enter()
        try OstAPIDeviceManager(userId: self.userId)
            .getDeviceManager(
                onSuccess: { (ostDeviceManager) in
                    
                    self.deviceManager = ostDeviceManager
                    group.leave()
            }) { (ostError) in
                
                error = ostError
                group.leave()
        }
        group.wait()
        
        if (nil != error) {
            throw error!
        }
    }
    
    /// Authorize
    func authorize() {
        do {
            let encodedABIHex = try getEncodedABI()
            
            let deviceManagerNonce: Int = self.deviceManager!.nonce
            
            guard let toAddress = getToAddress() else {
                throw OstError("w_a_ab_a_1", .toAddressNotFound)
            }
            
            let typedDataInput: [String: Any] = try GnosisSafe().getSafeTxData(verifyingContract: self.deviceManager!.address!,
                                                                               to: toAddress,
                                                                               value: "0",
                                                                               data: encodedABIHex,
                                                                               operation: "0",
                                                                               safeTxGas: "0",
                                                                               dataGas: "0",
                                                                               gasPrice: "0",
                                                                               gasToken: self.nullAddress,
                                                                               refundReceiver: self.nullAddress,
                                                                               nonce: OstUtils.toString(deviceManagerNonce)!)
            
            let eip712: EIP712 = EIP712(types: typedDataInput["types"] as! [String: Any],
                                        primaryType: typedDataInput["primaryType"] as! String,
                                        domain: typedDataInput["domain"] as! [String: String],
                                        message: typedDataInput["message"] as! [String: Any])
            
            let signingHash = try! eip712.getEIP712Hash()
            
            let (signature, signerAddress) = self.generateSignatureCallback(signingHash)
            
            if (nil == signature || signature!.isEmpty) {
                throw OstError("q_a_ab_a_2", .signatureGenerationFailed)
            }
            
            if (nil == signerAddress || signerAddress!.isEmpty) {
                throw OstError("q_a_ab_a_2", .signerAddressNotFound)
            }
            
            let rawCallData: String = getRawCallData()
            
            let params: [String: Any] = ["to": toAddress,
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

            try self.deviceManager?.incrementNonce()
            try apiRequestForAuthorize(params: params)
        }catch let error {
            onFailure(error as! OstError)
        }
    }
    
    //MARK: - Methods to override
    
    /// Get Encoded abi
    ///
    /// - Returns: Encoed abi hex value
    /// - Throws: OstError
    func getEncodedABI() throws -> String {
        fatalError("getEncodedABI is not override.")
    }
    
    /// Get raw calldata
    ///
    /// - Returns: raw calldata JSON string
    func getRawCallData() -> String {
        fatalError("getRawCallData is not override.")
    }

    /// Make API request to authorize
    ///
    /// - Parameter params: API request parameters
    /// - Throws: OstError
    func apiRequestForAuthorize(params: [String: Any]) throws {
        fatalError("apiRequestForAuthorize is not override.")
    }
    
    /// To address
    ///
    /// - Returns: to address for authorize
    func getToAddress() -> String? {
        fatalError("getToForTypeData is not override.")
    }
}
