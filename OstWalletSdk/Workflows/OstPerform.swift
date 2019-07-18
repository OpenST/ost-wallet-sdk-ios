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
        
        let jsonObj:[String:Any?]?;
        do {
            jsonObj = try OstUtils.toJSONObject(self.payloadString!) as? [String : Any?];
        } catch {
            throw OstError("w_p_vp_3", .invalidQRCode);
        }
        
        if ( nil == jsonObj) {
            throw OstError("w_p_vp_4", .invalidQRCode);
        }
        //Make sure data defination is present and is correct data-defination.
        guard let dataDefination = (jsonObj!["dd"] as? String)?.uppercased() else {
            throw OstError("w_p_vp_5", .invalidQRCode);
        }
        self.dataDefination = dataDefination;
        
        guard let _ = OstUtils.toString(jsonObj!["ddv"] as Any?)?.uppercased() else {
            throw OstError("w_p_vp_6", .invalidQRCode);
        }
        
        //Make sure payload data is present.
        guard let payloadData = jsonObj!["d"] as? [String: Any?] else {
            throw OstError("w_p_vp_7", .invalidQRCode);
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
        return OstWorkflowContext(workflowType: .performQRAction)
    }
}
