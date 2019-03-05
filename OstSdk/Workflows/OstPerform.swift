//
//  OstPerform.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public enum OstQRCodeDataDefination: String {
    case AUTHORIZE_DEVICE = "AUTHORIZE_DEVICE"
    case TRANSACTION = "TX"
}

class OstPerform: OstWorkflowBase {
    let ostPerformQueue = DispatchQueue(label: "com.ost.sdk.OstPerform", qos: .background)
    
    let payloadString: String?
    
    var dataDefination: String? = nil
    var payloadData: [String: Any?]?;
    
    init(userId: String, payload: String?, delegate: OstWorkFlowCallbackProtocol) {
        self.payloadString = payload;
        super.init(userId: userId, delegate: delegate)
    }
    
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostPerformQueue
    }
    
    override func process() throws {
        try parseQRCodeString()
        try self.startSubWorkflow();
    }
    
    override func validateParams() throws {
        try super.validateParams()
        
        if (nil == self.currentDevice) {
            throw OstError.init("w_p_p_1", .deviceNotset)
        }
        if (!self.currentDevice!.isStatusAuthorized) {
            throw OstError.init("w_p_p_2", OstErrorText.deviceNotAuthorized)
        }
    }
    
    func parseQRCodeString() throws {
        if ( nil == self.payloadString) {
            throw OstError("w_p_pqrcs_1", OstErrorText.invalidQRCode);
        }
        if ( 0 == self.payloadString?.count ) {
            throw OstError("w_p_pqrcs_2", OstErrorText.invalidQRCode);
        }
        let jsonObj:[String:Any?]?;
        do {
            jsonObj = try OstUtils.toJSONObject(self.payloadString!) as? [String : Any?];
        } catch _ {
            throw OstError("w_p_pqrcs_3", OstErrorText.invalidQRCode);
        }
        
        if ( nil == jsonObj) {
            throw OstError("w_p_pqrcs_4", OstErrorText.invalidQRCode);
        }
        
        //Make sure data defination is present and is correct data-defination.
        guard let dataDefination = (jsonObj!["dd"] as? String)?.uppercased() else {
            throw OstError("w_p_pqrcs_5", OstErrorText.invalidQRCode);
        }
        
        let validDefinations:[String] = [OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue,
                                         OstQRCodeDataDefination.TRANSACTION.rawValue];
        
        if ( validDefinations.contains(dataDefination) ) {
            self.dataDefination = dataDefination;
        } else {
            throw OstError("w_p_pqrcs_6", OstErrorText.invalidQRCode);
        }
        
        //Make sure payload data is present.
        guard let payloadData = jsonObj!["d"] as? [String: Any?] else {
            throw OstError("w_p_pqrcs_7", OstErrorText.invalidQRCode);
        }
        self.payloadData = payloadData;
            

    }

    func startSubWorkflow() throws {
        switch self.dataDefination {
        case OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue:
            let deviceAddress = try OstAddDeviceWithQRData.getAddDeviceParamsFromQRPayload(self.payloadData!)
            OstAddDeviceWithQRData(userId: self.userId,
                                   deviceAddress: deviceAddress,
                                   delegate: self.delegate).perform()
            
        case OstQRCodeDataDefination.TRANSACTION.rawValue:
            let executeTxPayloadParams = try OstExecuteTransaction.getExecuteTransactionParamsFromQRPayload(self.payloadData!)
            OstExecuteTransaction(userId: self.userId,
                                  ruleName: executeTxPayloadParams.ruleName,
                                  tokenHolderAddresses: executeTxPayloadParams.addresses,
                                  amounts: executeTxPayloadParams.amounts,
                                  tokenId: executeTxPayloadParams.tokenId,
                                  delegate: self.delegate).perform()
        default:
            throw OstError("w_p_sswf_1", OstErrorText.invalidQRCode);
        }
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .scanQRCode)
    }
}
