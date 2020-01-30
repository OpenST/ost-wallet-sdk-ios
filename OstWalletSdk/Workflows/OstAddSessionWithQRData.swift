/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

struct OstAddSessionQRStruct {
	let deviceAddress: String
	let sessionAddress: String
	let expiryTime: String
	let spendingLimit: String
	let signature: String
	
	var expireAfter: TimeInterval {
		let timeDiff = Int(expiryTime)! - Date.timestamp()
		return TimeInterval(timeDiff)
	}
}


class OstAddSessionWithQRData: OstAddSession, OstDataDefinitionWorkflow {
	
	static private let PAYLOAD_SESSION_DATA_KEY = "sd"
	static private let PAYLOAD_SIGNATURE_KEY = "sig"
	
	static private let PAYLOAD_DEVICE_ADDRESS_KEY = "da"
	static private let PAYLOAD_SESSION_ADDRESS_KEY = "sa"
	static private let PAYLOAD_SPENDING_LIMIT_KEY = "sl"
	static private let PAYLOAD_EXPIRY_TIME_KEY = "et"
	
	class func getAddSessionParamsFromQRPayload(_ payload: [String: Any?]) throws -> OstAddSessionQRStruct {
		guard let sessionData: [String: String] = payload[OstAddSessionWithQRData.PAYLOAD_SESSION_DATA_KEY] as? [String: String] else {
            throw OstError("w_aswqrd_gadpfqrp_1", .invalidQRCode)
        }
		
		guard let signature: String = payload[OstAddSessionWithQRData.PAYLOAD_SIGNATURE_KEY] as? String else {
            throw OstError("w_aswqrd_gadpfqrp_2", .invalidQRCode)
        }
		if signature.isEmpty {
            throw OstError("w_aswqrd_gadpfqrp_3", .invalidQRCode)
        }
		
		guard let deviceAddress: String = sessionData[OstAddSessionWithQRData.PAYLOAD_DEVICE_ADDRESS_KEY] else {
            throw OstError("w_aswqrd_gadpfqrp_4", .invalidQRCode)
        }
        if deviceAddress.isEmpty {
            throw OstError("w_aswqrd_gadpfqrp_5", .invalidQRCode)
        }
		
		guard let sessionAddress: String = sessionData[OstAddSessionWithQRData.PAYLOAD_SESSION_ADDRESS_KEY] else {
			throw OstError("w_aswqrd_gadpfqrp_6", .invalidQRCode)
		}
		if sessionAddress.isEmpty {
			throw OstError("w_aswqrd_gadpfqrp_7", .invalidQRCode)
		}
		
		guard let expiryTime: String = sessionData[OstAddSessionWithQRData.PAYLOAD_EXPIRY_TIME_KEY] else {
			throw OstError("w_aswqrd_gadpfqrp_8", .invalidQRCode)
		}
		if expiryTime.isEmpty {
			throw OstError("w_aswqrd_gadpfqrp_9", .invalidQRCode)
		}
       
		guard let spendingLimit: String = sessionData[OstAddSessionWithQRData.PAYLOAD_SPENDING_LIMIT_KEY] else {
			throw OstError("w_aswqrd_gadpfqrp_10", .invalidQRCode)
		}
		if spendingLimit.isEmpty {
			throw OstError("w_aswqrd_gadpfqrp_11", .invalidQRCode)
		}
		
		return OstAddSessionQRStruct(deviceAddress: deviceAddress,
									 sessionAddress: sessionAddress,
									 expiryTime: expiryTime,
									 spendingLimit: spendingLimit,
									 signature: signature)
    }

    static private let ostAddSessionWithQRDataQueue = DispatchQueue(label: "com.ost.sdk.OstAddSessionWithQRData", qos: .userInitiated)
	
	private let addSessionQRStruct: OstAddSessionQRStruct
	private var sessionDevice: OstDevice?
	
	/// Initialize
	/// - Parameters:
	///   - userId: Ost user id
	///   - addSessionQRStruct: OstAddSessionQRStruct
	///   - delegate: Callback
	init(userId: String,
		 addSessionQRStruct: OstAddSessionQRStruct,
		 delegate: OstWorkflowDelegate) {
		
		self.addSessionQRStruct = addSessionQRStruct

		super.init(userId: userId,
				   spendingLimit: addSessionQRStruct.spendingLimit,
				   expireAfter: addSessionQRStruct.expireAfter,
				   delegate: delegate)
	}
	
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstAddSessionWithQRData.ostAddSessionWithQRDataQueue
    }

	/// Validate params.
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()

		if !self.addSessionQRStruct.deviceAddress.isValidAddress {
            throw OstError("w_aswqrd_vp_1", .unknown);
        }
		if !self.addSessionQRStruct.sessionAddress.isValidAddress{
            throw OstError("w_aswqrd_vp_2", .unknown);
        }
		
		try fetchDevice()
    }
	
    /// Fetch device to validate mnemonics
    ///
    /// - Throws: OstError
    private func fetchDevice() throws {
        if nil == self.sessionDevice {
            var error: OstError? = nil
            let group = DispatchGroup()
            group.enter()
            try OstAPIDevice(userId: userId)
				.getDevice(deviceAddress: self.addSessionQRStruct.deviceAddress,
                           onSuccess: { (ostDevice) in
                            self.sessionDevice = ostDevice
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
        
		if (self.sessionDevice!.userId!.caseInsensitiveCompare(self.currentDevice!.userId!) != .orderedSame){
			throw OstError("w_adwqrd_fd_2", .unknown)
		}
    }
	
	/// Proceed with workflow after user is authenticated.
		override func onUserAuthenticated() throws {
		   _ = try syncDeviceManager()
		   self.sessionData = try OstAddSessionQRHelper(userId: self.userId,
														sessionAddress: self.addSessionQRStruct.sessionAddress,
														expiresAfter: self.addSessionQRStruct.expireAfter,
														spendingLimit: self.addSessionQRStruct.spendingLimit).getSessionData()
		   try self.authorizeSession()
	   }
	
	
	/// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
		let sessionEntity: OstSession = try! OstSession([
			"address": self.addSessionQRStruct.sessionAddress,
			"user_ud": self.userId,
			"spending_limit": self.addSessionQRStruct.spendingLimit,
			"expiration_height": self.addSessionQRStruct.expiryTime,
			"nonce": "0",
			"approx_expiration_timestamp": "0"
		])
        return OstContextEntity(entity: sessionEntity, entityType: .session)
    }
	
	override func getWorkflowContext() -> OstWorkflowContext {
		return OstWorkflowContext(workflowId: self.workflowId, workflowType: .authorizeSessionWithQRCode)
	}
	
	//MARK: - OstDataDefinitionWorkflow
	/// Validate data defination dependent parameters.
	///
	/// - Throws: OstError
	func validateApiDependentParams() throws {
		try self.validateParams()
		try self.fetchDevice()
		//validate signature
	}
	
//	func getPersonalSignAddress(signature: String, of message: String, compressed: Bool = false) -> String {
//        var sig = Data(hex: signature)
//        if sig[64] != 27 && sig[64] != 28 {
//            fatalError()
//        }
//        sig[64] = sig[64] - 27
//        let messageHash = generatePersonalMessageHash(message: message);
//        let publicKeyData = Crypto.publicKey(signature: sig, of: messageHash, compressed: compressed)!;
//        let publicKey = PublicKey(raw: publicKeyData);
//        return publicKey.address();
//    }
//    func generatePersonalMessageHash(message: String) -> Data {
//        let hexString = message.toHexString()
//        let prefix = "\u{19}Ethereum Signed Message:\n"
//        let messageData = Data(hex: hexString.stripHexPrefix())
//        let prefixData = (prefix + String(messageData.count)).data(using: .ascii)!
//        return Crypto.hashSHA3_256(prefixData + messageData)
//    }
	
	
	func getDataDefinitionContextEntity() -> OstContextEntity {
		return self.getContextEntity(for: self.addSessionQRStruct)
	}
	
	func getDataDefinitionWorkflowContext() -> OstWorkflowContext {
		return self.getWorkflowContext()
	}
	
	func startDataDefinitionFlow() {
		 performState(OstWorkflowStateManager.INITIAL)
	}
}
