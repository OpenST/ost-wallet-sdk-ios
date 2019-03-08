//
//  OstPerform.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

enum OstQRCodeDataDefination: String {
    case AUTHORIZE_DEVICE = "AUTHORIZE_DEVICE"
    case TRANSACTION = "TX"
}

class OstPerform: OstWorkflowBase, OstValidateDataProtocol {
    private let ostPerformQueue = DispatchQueue(label: "com.ost.sdk.OstPerform", qos: .background)
    private let payloadString: String?
    
    private var dataDefination: String? = nil
    private var payloadData: [String: Any?]?;
    private var executeTxPayloadParams: OstExecuteTransaction.ExecuteTransactionPayloadParams? = nil
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - payload: QR-Code payload
    ///   - delegate: Callback
    init(userId: String,
         payload: String?,
         delegate: OstWorkFlowCallbackProtocol) {
        
        self.payloadString = payload;
        super.init(userId: userId, delegate: delegate)
    }
    
    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostPerformQueue
    }
    
    /// validate parameters
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        try self.workFlowValidator!.isDeviceAuthorized()
        
        if ( nil == self.payloadString) {
            throw OstError("w_p_vp_1", OstErrorText.invalidQRCode);
        }
        if ( 0 == self.payloadString!.count ) {
            throw OstError("w_p_vp_2", OstErrorText.invalidQRCode);
        }
        
    }
    
    /// process workflow.
    ///
    /// - Throws: OstError
    override func process() throws {
        try parseQRCodeString()
        try self.startSubWorkflow();
    }

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
                                         OstQRCodeDataDefination.TRANSACTION.rawValue];
        
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
                                   delegate: self.delegate).perform()
            
        case OstQRCodeDataDefination.TRANSACTION.rawValue:
            let executeTxPayloadParams = try OstExecuteTransaction.getExecuteTransactionParamsFromQRPayload(self.payloadData!)
            self.executeTxPayloadParams = executeTxPayloadParams
            verifyDataForExecuteTransaction(executeTxPayloadParams)
        default:
            throw OstError("w_p_sswf_1", OstErrorText.invalidQRCode);
        }
    }
    
    /// Verify data from user about transaction through QR-Code
    ///
    /// - Parameter executeTxPayloadParams: ExecuteTxPayloadParams
    private func verifyDataForExecuteTransaction(_ executeTxPayloadParams: OstExecuteTransaction.ExecuteTransactionPayloadParams) {
        let tokenHolderAddresses = executeTxPayloadParams.addresses
        let amounts = executeTxPayloadParams.amounts
        
        var stringToConfirm: String = ""
        stringToConfirm += "rule name : \(executeTxPayloadParams.ruleName)"
        
        for (i, address) in tokenHolderAddresses.enumerated() {
            stringToConfirm += "\n\(address): \(amounts[i])"
        }
        
        let workflowContext = OstWorkflowContext(workflowType: .executeTransaction);
        let contextEntity: OstContextEntity = OstContextEntity(entity: stringToConfirm, entityType: .string)
        DispatchQueue.main.async {
            self.delegate.verifyData(workflowContext: workflowContext,
                                     ostContextEntity: contextEntity,
                                     delegate: self)
        }
    }
    
    public func dataVerified() {
        OstExecuteTransaction(userId: self.userId,
                              ruleName: self.executeTxPayloadParams!.ruleName,
                              tokenHolderAddresses: self.executeTxPayloadParams!.addresses,
                              amounts: self.executeTxPayloadParams!.amounts,
                              tokenId: self.executeTxPayloadParams!.tokenId,
                              delegate: self.delegate).perform()
    }

    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .scanQRCode)
    }
}
