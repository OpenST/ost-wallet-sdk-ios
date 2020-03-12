/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

enum OstQRCodeDataDefination: String {
	case AUTHORIZE_SESSION = "AS"
    case AUTHORIZE_DEVICE = "AD"
    case TRANSACTION = "TX"
    case REVOKE_DEVICE = "RD"
}

class OstPerform: OstWorkflowEngine, OstValidateDataDelegate {
    static private let ostPerformQueue = DispatchQueue(label: "com.ost.sdk.OstPerform", qos: .background)
    private let payloadString: String?
    
    private var dataDefination: String? = nil
    private var payloadData: [String: Any?]? = nil
    private var meta: [String: Any?]? = nil
    private var executeTxPayloadParams: OstExecuteTransaction.ExecuteTransactionPayloadParams? = nil
    private var dataDefinationWorkflow: OstDataDefinitionWorkflow?
	
	static let V2_QR_SEPERATOR = "|"
    
	var QRData: [String: Any?]? = nil
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - payload: QR-Code payload
    ///   - delegate: Callback
    init(userId: String,
         payload: String?,
         delegate: OstWorkflowDelegate) {
        
        self.payloadString = payload;
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Sets in ordered states for current Workflow
    ///
    /// - Returns: Order states array
    override func getOrderedStates() -> [String] {
        var orderedStates:[String] = super.getOrderedStates()
        
        var inBetweenOrderedStates = [String]()
        inBetweenOrderedStates.append(OstWorkflowStateManager.VERIFY_DATA)
        inBetweenOrderedStates.append(OstWorkflowStateManager.DATA_VERIFIED)
        
        orderedStates.insert(contentsOf:inBetweenOrderedStates, at:3)
        return orderedStates
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return OstPerform.ostPerformQueue
    }
    
    /// Process workflow
    ///
    /// - Throws: OstError
    override func process() throws {
        switch self.workflowStateManager.getCurrentState() {
        case OstWorkflowStateManager.DEVICE_VALIDATED:
            try self.dataDefinationWorkflow!.validateApiDependentParams()
            try processNext()
            
        case OstWorkflowStateManager.VERIFY_DATA:
            verifyDataFromUser()
            
        case OstWorkflowStateManager.DATA_VERIFIED:
            self.dataDefinationWorkflow!.startDataDefinitionFlow()
            
        default:
            try super.process()
        }
    }
    
    /// validate parameters
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        
        if ( nil == self.payloadString) {
            throw OstError("w_p_vp_1", .invalidQRCode);
        }
        if ( 0 == self.payloadString!.count ) {
            throw OstError("w_p_vp_2", .invalidQRCode);
        }
        
		let jsonObj:[String:Any?] = try OstPerform.getJsonObject(self.payloadString!)
		self.QRData = jsonObj
		
        //Make sure data defination is present and is correct data-defination.
        guard let dataDefination = (jsonObj["dd"] as? String)?.uppercased() else {
            throw OstError("w_p_vp_3", .invalidQRCode);
        }
        self.dataDefination = dataDefination;
        
        guard let _ = OstUtils.toString(jsonObj["ddv"] as Any?)?.uppercased() else {
            throw OstError("w_p_vp_4", .invalidQRCode);
        }
        
        //Make sure payload data is present.
        guard let payloadData = jsonObj["d"] as? [String: Any?] else {
            throw OstError("w_p_vp_5", .invalidQRCode);
        }
        self.payloadData = payloadData;
        
        if let payloadMeta = jsonObj["m"] as? [String: Any?] {
            self.meta = payloadMeta
        }
        
        self.dataDefinationWorkflow = try getWorkFlowObject()
    }
    
    /// Get workflow object for provided
    ///
    /// - Returns: OstDataDefinitionWorkflow
    /// - Throws: OstError
    private func getWorkFlowObject() throws -> OstDataDefinitionWorkflow {
        
        switch self.dataDefination! {
        case OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue:
            let deviceAddress = try OstAddDeviceWithQRData.getAddDeviceParamsFromQRPayload(self.payloadData!)
            return OstAddDeviceWithQRData(userId: self.userId,
                                          deviceAddress: deviceAddress,
                                          delegate: self.delegate!)
            
        case OstQRCodeDataDefination.REVOKE_DEVICE.rawValue:
            let deviceAddress = try OstRevokeDeviceWithQRData.getRevokeDeviceParamsFromQRPayload(self.payloadData!)
            return OstRevokeDeviceWithQRData(userId: self.userId,
                                             deviceAddressToRevoke: deviceAddress,
                                             delegate: self.delegate!)
            
        case OstQRCodeDataDefination.TRANSACTION.rawValue:
             let executeTxPayloadParams = try OstExecuteTransaction.getExecuteTransactionParamsFromQRPayload(self.payloadData!)
             if (self.currentUser!.tokenId! != executeTxPayloadParams.tokenId) {
                 throw OstError("w_p_gwfo_1", .invalidTokenId)
             }
             let metaParam = OstExecuteTransaction.getTransactionMetaFromFromQRPayload(self.meta)
             
             self.executeTxPayloadParams = executeTxPayloadParams
            
            return OstExecuteTransaction(userId: self.userId,
                                         ruleName: executeTxPayloadParams.ruleName,
                                         toAddresses: executeTxPayloadParams.addresses,
                                         amounts: executeTxPayloadParams.amounts,
                                         transactionMeta: metaParam,
                                         options: executeTxPayloadParams.options,
                                         delegate: self.delegate!)
		
		case OstQRCodeDataDefination.AUTHORIZE_SESSION.rawValue:
			let autorizeSessionParams = try OstAddSessionWithQRData.getAddSessionParamsFromQRPayload(self.payloadData!)
			return OstAddSessionWithQRData(userId: userId,
										   addSessionQRStruct: autorizeSessionParams,
										   qrVersion: QRData!["ddv"] as! String,
										   qrData: QRData!,
										   delegate: self.delegate!)
        default:
            throw OstError("w_p_gwfo_1", .invalidQRCode);
        }
    }

    /// Verify QR-Code data from user
    func verifyDataFromUser() {
        
        let contextEntity = self.dataDefinationWorkflow!.getDataDefinitionContextEntity()
        let workflowContext = self.dataDefinationWorkflow!.getDataDefinitionWorkflowContext()
        
        DispatchQueue.main.async {
            self.delegate?.verifyData(workflowContext: workflowContext,
                                      ostContextEntity: contextEntity,
                                      delegate: self)
        }
    }
    
    /// Callback on user verified QR-Code data
    public func dataVerified() {
        performState(OstWorkflowStateManager.DATA_VERIFIED)
    }

    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .performQRAction)
    }
}

extension OstPerform {
	class func getJsonObject(_ payloadString: String) throws -> [String: Any?] {
		var jsonObj: [String:Any?]? = nil
		
		if let v2JsonObj: [String: Any?] = self.getJsonObjectFromV2QR(payloadString) {
			jsonObj = v2JsonObj
		}
		
		if (nil == jsonObj) {
			do {
				jsonObj = try OstUtils.toJSONObject(payloadString) as? [String : Any?];
			} catch {
				throw OstError("w_p_gjo_1", .invalidQRCode);
			}
		}
        
		if (nil == jsonObj) {
			throw OstError("w_p_gjo_2", .invalidQRCode);
		}
		return jsonObj!
	}
	
	class func getJsonObjectFromV2QR(_ v2QrString: String) -> [String: Any?]? {
		let parts: [String] = v2QrString.components(separatedBy: OstPerform.V2_QR_SEPERATOR)
		
		if ( parts.count < 7 ) {
            //Does not have sufficient parts.
			return nil;
        }
			
		if OstQRCodeDataDefination.AUTHORIZE_SESSION.rawValue.caseInsensitiveCompare(parts[0]) != .orderedSame {
			return nil
		}
		
		var jsonData: [String: Any] = [:]
		jsonData["dd"] = parts[0]
		jsonData["ddv"] = parts[1]
		
		let sessionData = [
			OstAddSessionWithQRData.PAYLOAD_DEVICE_ADDRESS_KEY : parts[2].addHexPrefix(),
			OstAddSessionWithQRData.PAYLOAD_SESSION_ADDRESS_KEY : parts[3].addHexPrefix(),
			OstAddSessionWithQRData.PAYLOAD_SPENDING_LIMIT_KEY : parts[4],
			OstAddSessionWithQRData.PAYLOAD_EXPIRY_TIME_KEY : parts[5]
		]
		
		jsonData["d"] = [
			OstAddSessionWithQRData.PAYLOAD_SESSION_DATA_KEY: sessionData,
			OstAddSessionWithQRData.PAYLOAD_SIGNATURE_KEY: parts[6]
		]
		
		jsonData["qr_v2_input"] = v2QrString
		
		print("jsonData : ", jsonData);
		return jsonData
	}
}
