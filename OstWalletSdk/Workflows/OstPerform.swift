/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

enum OstQRCodeDataDefination: String {
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
    
    override func getInBetweenOrderedStates() -> [String] {
        var orderedStates = [String]()
        
        orderedStates.append(OstWorkflowStateManager.VERIFY_DATA)
        orderedStates.append(OstWorkflowStateManager.DATA_VERIFIED)
        
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
            try processNext()

//            let contextEntity = self.dataDefinationWorkflow!.getContextEntity()
//            let workflowContext = self.dataDefinationWorkflow!.getWorkflowContext()
            
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
            throw OstError("w_p_vp_1", OstErrorText.invalidQRCode);
        }
        if ( 0 == self.payloadString!.count ) {
            throw OstError("w_p_vp_2", OstErrorText.invalidQRCode);
        }
        
        let jsonObj:[String:Any?]?;
        do {
            jsonObj = try OstUtils.toJSONObject(self.payloadString!) as? [String : Any?];
        } catch {
            throw OstError("w_p_pqrcs_1", OstErrorText.invalidQRCode);
        }
        
        if ( nil == jsonObj) {
            throw OstError("w_p_pqrcs_2", OstErrorText.invalidQRCode);
        }
        //Make sure data defination is present and is correct data-defination.
        guard let dataDefination = (jsonObj!["dd"] as? String)?.uppercased() else {
            throw OstError("w_p_pqrcs_3", OstErrorText.invalidQRCode);
        }
        self.dataDefination = dataDefination;
        
        guard let _ = (jsonObj!["ddv"] as? String)?.uppercased() else {
            throw OstError("w_p_pqrcs_4", OstErrorText.invalidQRCode);
        }
        
        //Make sure payload data is present.
        guard let payloadData = jsonObj!["d"] as? [String: Any?] else {
            throw OstError("w_p_pqrcs_5", OstErrorText.invalidQRCode);
        }
        self.payloadData = payloadData;
        
        if let payloadMeta = jsonObj!["m"] as? [String: Any?] {
            self.meta = payloadMeta
        }
        
        self.dataDefinationWorkflow = try getWorkFlowObject()
    }
    
    private func getWorkFlowObject() throws -> OstDataDefinitionWorkflow {
        
        switch self.dataDefination! {
        case OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue:
            let deviceAddress = try OstAddDeviceWithQRData.getAddDeviceParamsFromQRPayload(self.payloadData!)
            return OstAddDeviceWithQRData(userId: self.userId,
                                          deviceAddress: deviceAddress,
                                          delegate: self.delegate!)
            
//        case OstQRCodeDataDefination.TRANSACTION.rawValue:
//            return
//        case OstQRCodeDataDefination.REVOKE_DEVICE.rawValue:
//            return
        default:
            throw OstError("w_p_gwfo_1", OstErrorText.invalidQRCode);
        }
    }
    
    /// process workflow.
    ///
    /// - Throws: OstError
//    override func process() throws {
//        try parseQRCodeString()
//        try self.startSubWorkflow();
//    }

    /// Parse QR-Code data
    ///
    /// - Throws: OstError
    private func parseQRCodeString() throws {
       
        let jsonObj:[String:Any?]?;
        do {
            jsonObj = try OstUtils.toJSONObject(self.payloadString!) as? [String : Any?];
        } catch {
            throw OstError("w_p_pqrcs_1", OstErrorText.invalidQRCode);
        }
        
        if ( nil == jsonObj) {
            throw OstError("w_p_pqrcs_2", OstErrorText.invalidQRCode);
        }
        //Make sure data defination is present and is correct data-defination.
        guard let dataDefination = (jsonObj!["dd"] as? String)?.uppercased() else {
            throw OstError("w_p_pqrcs_3", OstErrorText.invalidQRCode);
        }
        
        let validDefinations:[String] = [OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue,
                                         OstQRCodeDataDefination.TRANSACTION.rawValue,
                                         OstQRCodeDataDefination.REVOKE_DEVICE.rawValue];
        
        if ( validDefinations.contains(dataDefination) ) {
            self.dataDefination = dataDefination;
        } else {
            throw OstError("w_p_pqrcs_4", OstErrorText.invalidQRCode);
        }
        
        //Make sure payload data is present.
        guard let payloadData = jsonObj!["d"] as? [String: Any?] else {
            throw OstError("w_p_pqrcs_5", OstErrorText.invalidQRCode);
        }
        self.payloadData = payloadData;
        
        if let payloadMeta = jsonObj!["m"] as? [String: Any?] {
            self.meta = payloadMeta
        }
    }

    /// Delegate process to respective workflow
    ///
    /// - Throws: OstError
    private func startSubWorkflow() throws {
        switch self.dataDefination {
        case OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue:
            let deviceAddress = try OstAddDeviceWithQRData.getAddDeviceParamsFromQRPayload(self.payloadData!)
            OstAddDeviceWithQRData(userId: self.userId,
                                   deviceAddress: deviceAddress,
                                   delegate: self.delegate!).perform()
            
        case OstQRCodeDataDefination.TRANSACTION.rawValue:
            let executeTxPayloadParams = try OstExecuteTransaction.getExecuteTransactionParamsFromQRPayload(self.payloadData!)
            if (self.currentUser!.tokenId! != executeTxPayloadParams.tokenId) {
                throw OstError("w_p_ssw_1", OstErrorText.invalidTokenId)
            }
            self.executeTxPayloadParams = executeTxPayloadParams
            verifyDataForExecuteTransaction(executeTxPayloadParams)
            
        case OstQRCodeDataDefination.REVOKE_DEVICE.rawValue:
            let deviceAddress = try OstRevokeDeviceWithQRData.getRevokeDeviceParamsFromQRPayload(self.payloadData!)
            OstRevokeDeviceWithQRData(userId: self.userId,
                                      deviceAddressToRevoke: deviceAddress,
                                      delegate: self.delegate!).perform()
            
        default:
            throw OstError("w_p_sswf_1", OstErrorText.invalidQRCode);
        }
    }
    
    /// Verify data from user about transaction through QR-Code
    ///
    /// - Parameter executeTxPayloadParams: ExecuteTxPayloadParams
    private func verifyDataForExecuteTransaction(_ executeTxPayloadParams: OstExecuteTransaction.ExecuteTransactionPayloadParams) {
        let workflowContext = OstWorkflowContext(workflowType: .executeTransaction);
        
        let verifyData: [String: Any] = [
            "rule_name": executeTxPayloadParams.ruleName,
            "token_holder_addresses": executeTxPayloadParams.addresses,
            "amounts": executeTxPayloadParams.amounts,
            "token_id": executeTxPayloadParams.tokenId
        ]

        let contextEntity: OstContextEntity = OstContextEntity(entity: verifyData, entityType: .dictionary)
        DispatchQueue.main.async {
            self.delegate?.verifyData(workflowContext: workflowContext,
                                     ostContextEntity: contextEntity,
                                     delegate: self)
        }
    }
    
    public func dataVerified() {
        
        let transactionMeta: [String: String] = OstExecuteTransaction.getTransactionMetaFromFromQRPayload(self.meta)
        OstExecuteTransaction(userId: self.userId,
                              ruleName: self.executeTxPayloadParams!.ruleName,
                              toAddresses: self.executeTxPayloadParams!.addresses,
                              amounts: self.executeTxPayloadParams!.amounts,
                              transactionMeta: transactionMeta,
                              delegate: self.delegate!).perform()
    }

    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .performQRAction)
    }
}
