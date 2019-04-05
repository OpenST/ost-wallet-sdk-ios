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
    
    /// Get in betweeen ordered states
    ///
    /// - Returns: States array
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
            verifyDataFromUser()
            
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
        
        guard let _ = OstUtils.toString(jsonObj!["ddv"] as Any?)?.uppercased() else {
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
            
        default:
            throw OstError("w_p_gwfo_1", OstErrorText.invalidQRCode);
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
        self.dataDefinationWorkflow!.startDataDefinitionFlow()
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
    
    

    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .performQRAction)
    }
}
