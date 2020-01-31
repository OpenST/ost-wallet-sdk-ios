/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import EthereumKit

struct OstAddSessionQRStruct {
	let deviceAddress: String
	let sessionAddress: String
	let expiryTime: String
	let spendingLimit: String
	let signature: String
	
	var lowestSpendingLimit: String?
	var heigestSpendingLimit: String?

	
	var expireAfter: TimeInterval {
		let timeDiff = Int(expiryTime)! - Date.timestamp()
		return TimeInterval(timeDiff)
	}
	
	mutating func toLowestUnitSpendingLimit(tokenId: String) -> String? {
		self.lowestSpendingLimit = try? OstConversion.toLowestUnit(spendingLimit, tokenId: tokenId)
		return lowestSpendingLimit
	}
	
	mutating func toHeighestUnitSpendingLimit(tokenId: String) -> String? {
		self.heigestSpendingLimit = try? OstConversion.toHighestUnit(spendingLimit, tokenId: tokenId)
		return heigestSpendingLimit
	}
}


class OstAddSessionWithQRData: OstAddSession, OstDataDefinitionWorkflow {
	
	static  let PAYLOAD_SESSION_DATA_KEY = "sd"
	static  let PAYLOAD_SIGNATURE_KEY = "sig"
	
	static  let PAYLOAD_DEVICE_ADDRESS_KEY = "da"
	static  let PAYLOAD_SESSION_ADDRESS_KEY = "sa"
	static  let PAYLOAD_SPENDING_LIMIT_KEY = "sl"
	static  let PAYLOAD_EXPIRY_TIME_KEY = "et"
	
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
	
	private var addSessionQRStruct: OstAddSessionQRStruct
	private var sessionDevice: OstDevice?
	private var session: OstSession?
	private var qrVersion: String
	private var qrData: [String: Any?]
	
	/// Initialize
	/// - Parameters:
	///   - userId: Ost user id
	///   - addSessionQRStruct: OstAddSessionQRStruct
	///   - delegate: Callback
	init(userId: String,
		 addSessionQRStruct: OstAddSessionQRStruct,
		 qrVersion: String,
		 qrData: [String: Any?],
		 delegate: OstWorkflowDelegate) {
		
		self.addSessionQRStruct = addSessionQRStruct
		self.qrVersion = qrVersion
		self.qrData = qrData
		
		var spendingLimit: String = addSessionQRStruct.spendingLimit
		if let user = try? OstUser.getById(userId),
			let tokenId = user?.tokenId {
			
			spendingLimit = self.addSessionQRStruct.toLowestUnitSpendingLimit(tokenId: tokenId) ?? spendingLimit
			print("spendingLimit : ", addSessionQRStruct.spendingLimit)
			print("spendingLimit : lowest val", spendingLimit)
		}
		
		super.init(userId: userId,
				   spendingLimit: spendingLimit,
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
			//todo: INVALID_SESSION_ADDRESS
            throw OstError("w_aswqrd_vp_2", .unknown);
        }
		
		try validateDevice()
		try validateSession()
    }
	
	func validateDevice() throws {
		try? self.fetchDevice()
			
		if (nil == sessionDevice) {
			//OstErrorCodes.OstErrorCode.INVALID_DEVICE_ADDRESS
			let error = OstError(internalCode: "w_oaswqrd_vd_1", errorCode: OstErrorCodes.OstErrorCode.unknown)
			error.addErrorInfo(key: "qr_device_address", val: addSessionQRStruct.deviceAddress)
			error.addErrorInfo(key: "userId", val: userId)
			error.addErrorInfo(key: "reason", val: "Device with specified address does not exist for this user")
			
			throw error
		}
		
		// Ensure device is in registered state.
		if (!sessionDevice!.isStatusRegistered) {
			//OstErrorCodes.OstErrorCode.INVALID_DEVICE_ADDRESS
			let error = OstError(internalCode: "w_oaswqrd_vadp_2", errorCode: OstErrorCodes.OstErrorCode.unknown)
			error.addErrorInfo(key: "qr_device_address", val: addSessionQRStruct.deviceAddress)
			error.addErrorInfo(key: "userId", val: userId)
			error.addErrorInfo(key: "device_status", val: sessionDevice!.status ?? "")
			error.addErrorInfo(key: "reason", val: "external session key to be authorized must be created from device with registered status");
			
			throw error
		}
	}
	
	func validateSession() throws {
		try? self.fetchSession()
		if (nil != session) {
			let error = OstError(internalCode: "w_oaswqrd_vs_1", errorCode: OstErrorCodes.OstErrorCode.unknown)
			error.addErrorInfo(key: "qr_session_address", val: addSessionQRStruct.sessionAddress)
			error.addErrorInfo(key: "userId", val: userId)
			error.addErrorInfo(key: "session_status", val: session!.status)
			error.addErrorInfo(key: "reason", val: "Session can not be authorized.");
		}
	}
	
    /// Fetch device
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
			throw OstError("w_adwqrd_fd_1", .unknown)
		}
    }
	
	/// Fetch session
    ///
    /// - Throws: OstError
    private func fetchSession() throws {
        if nil == self.session {
            var error: OstError? = nil
            let group = DispatchGroup()
            group.enter()
            try OstAPISession(userId: userId)
				.getSession(sessionAddress:  self.addSessionQRStruct.sessionAddress,
							onSuccess: { (ostSession) in
											self.session = ostSession
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
        
		if (nil != self.session){
			throw OstError("w_adwqrd_fs_1", .unknown)
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
			"user_id": self.userId,
			"spending_limit": self.addSessionQRStruct.lowestSpendingLimit ?? self.addSessionQRStruct.spendingLimit,
			"expiration_height": self.addSessionQRStruct.expiryTime,
			"nonce": "0",
			"approx_expiration_timestamp": self.addSessionQRStruct.expiryTime
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

		try ensureSessionDataSignedByApiSigner()
	}
	
	func ensureSessionDataSignedByApiSigner() throws {
		
		let message = getMessageToSign()
		
		guard let externalSignerAddress = sessionDevice?.apiSignerAddress else {
			let error = OstError(internalCode: "w_oaswqrd_esdsbas_1", errorCode: OstErrorCodes.OstErrorCode.invalidQRCode)
			error.addErrorInfo(key: "qr_external_device_api_signer", val: "null")
			throw error
		}
		
		let signerAddress = getPersonalSignAddress(signature: addSessionQRStruct.signature, of: message)
		
		if externalSignerAddress.caseInsensitiveCompare(signerAddress) != .orderedSame {
			//INVALID_SIGNATURE
			throw OstError(internalCode: "w_oaswqrd_esdsbas_2", errorCode: OstErrorCodes.OstErrorCode.signerAddressNotFound)
		}
	}
	
	func getMessageToSign() -> String{
		
		var parts: [String] = []
		
		parts.append( getDataDefination() )
		parts.append( getVersion() )
		parts.append( addSessionQRStruct.deviceAddress.stripHexPrefix() )
		parts.append( addSessionQRStruct.sessionAddress.stripHexPrefix() )
		parts.append( addSessionQRStruct.spendingLimit )
		parts.append( addSessionQRStruct.expiryTime )
		
		return parts.joined(separator: OstPerform.V2_QR_SEPERATOR).lowercased()
	}
	
	func getData() -> [String: Any]? {
		return qrData["d"] as? [String: Any]
	}
	
	func getSessionData() -> [String: Any]? {
		return getData()?[OstAddSessionWithQRData.PAYLOAD_SESSION_ADDRESS_KEY] as? [String: Any]
	}
	
	func getDataDefination() -> String {
		return qrData["dd"] as! String
	}
	
	func getVersion() -> String {
		return qrData["ddv"] as! String
	}
	
	func getPersonalSignAddress(signature: String, of message: String, compressed: Bool = false) -> String {
        var sig = Data(hex: signature)
        if sig[64] != 27 && sig[64] != 28 {
            fatalError()
        }
        sig[64] = sig[64] - 27
        let messageHash = generatePersonalMessageHash(message: message);
        let publicKeyData = Crypto.publicKey(signature: sig, of: messageHash, compressed: compressed)!;
        let publicKey = PublicKey(raw: publicKeyData);
        return publicKey.address();
    }
    func generatePersonalMessageHash(message: String) -> Data {
        let hexString = message.toHexString()
        let prefix = "\u{19}Ethereum Signed Message:\n"
        let messageData = Data(hex: hexString.stripHexPrefix())
        let prefixData = (prefix + String(messageData.count)).data(using: .ascii)!
        return Crypto.hashSHA3_256(prefixData + messageData)
    }
	
	
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
