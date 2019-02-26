//
//  OstPerform.swift
//  OstSdk
//
//  Created by aniket ayachit on 16/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public enum OstQRCodeDataDefination: String {
    case REVOKE_DEVICE = "REVOKE_DEVICE"
    case REVOKE_SESSION = "REVOKE_SESSION"
    case AUTHORIZE_DEVICE = "AUTHORIZE_DEVICE"
    case AUTHORIZE_SESSION = "AUTHORIZE_SESSION"
}

class OstPerform: OstWorkflowBase {
    let ostPerformThread = DispatchQueue(label: "com.ost.sdk.OstPerform", qos: .background)
    
    let payloadString: String?
    
    var dataDefination: String? = nil
    var payloadData: [String: Any?]?;
    var deviceManager: OstDeviceManager? = nil
    
    let threshold = "1"
    let nullAddress = "0x0000000000000000000000000000000000000000"
    
    init(userId: String, payload: String?, delegate: OstWorkFlowCallbackProtocol) {
        self.payloadString = payload;
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        ostPerformThread.async {
            do {
                //Validate payload. Before asking for authentication.
                try self.parseQRCodeString();
                
                guard let currentDevice: OstCurrentDevice = try self.getCurrentDevice() else {
                    throw OstError.invalidInput("Device is not setup. Please Setup device first. call OstSdk.setupDevice")
                }
                if (!currentDevice.isDeviceRegistered()) {
                    throw OstError.invalidInput("Device is not registered")
                }
                
                // Note: Authenticate user is not need before validating data.
                // Hence, removed self.authenticateUser()
                // proceedWorkflowAfterAuthenticateUser renamed as startSubWorkflow.
                // The sub workflow will authenticate-user as needed.
                try self.startSubWorkflow();
                
            } catch let error {
                self.postError(error)
            }
        }
    }
    
    func parseQRCodeString() throws {
        if ( nil == self.payloadString) {
            throw OstError1("w_p_pqrcs_1", OstErrorText.invalidQRCode);
        }
        if ( 0 == self.payloadString?.count ) {
            throw OstError1("w_p_pqrcs_2", OstErrorText.invalidQRCode);
        }
        let jsonObj:[String:Any?]?;
        do {
            jsonObj = try OstUtils.toJSONObject(self.payloadString!) as? [String : Any?];
        } catch _ {
            throw OstError1("w_p_pqrcs_3", OstErrorText.invalidQRCode);
        }
        
        if ( nil == jsonObj) {
            throw OstError1("w_p_pqrcs_4", OstErrorText.invalidQRCode);
        }
        
        //Make sure data defination is present and is correct data-defination.
        guard let dataDefination = jsonObj!["dd"] as? String else {
            throw OstError1("w_p_pqrcs_5", OstErrorText.invalidQRCode);
        }
        
        if ( ( OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue.caseInsensitiveCompare(dataDefination) == .orderedSame )
            || ( OstQRCodeDataDefination.REVOKE_DEVICE.rawValue.caseInsensitiveCompare(dataDefination) == .orderedSame )
            || ( OstQRCodeDataDefination.AUTHORIZE_SESSION.rawValue.caseInsensitiveCompare(dataDefination) == .orderedSame )
            || ( OstQRCodeDataDefination.REVOKE_SESSION.rawValue.caseInsensitiveCompare(dataDefination) == .orderedSame )
        ) {
            self.dataDefination = dataDefination;
        } else {
            throw OstError1("w_p_pqrcs_6", OstErrorText.invalidQRCode);
        }
        
        //Make sure payload data is present.
        guard let payloadData = jsonObj!["d"] as? [String: Any?] else {
            throw OstError1("w_p_pqrcs_7", OstErrorText.invalidQRCode);
        }
        self.payloadData = payloadData;
    }

    func startSubWorkflow() throws {
        switch self.dataDefination {
        case OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue:
            OstAddDeviceWithQRData(userId: self.userId,
                                   qrCodeData: payloadData!,
                                   delegate: self.delegate).perform()
            
        case OstQRCodeDataDefination.REVOKE_DEVICE.rawValue:
            //To-Do: Implement revoke device.
            return
            
        case OstQRCodeDataDefination.AUTHORIZE_SESSION.rawValue:
            //To-Do: Implement authorize session.
           return
            
        case OstQRCodeDataDefination.REVOKE_SESSION.rawValue:
            //To-Do: Implement revoke session.
            return
            
        default:
            throw OstError1("w_p_pwaau_1", OstErrorText.invalidQRCode);
        }
    }
    
    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .scanQRCode)
    }
}
