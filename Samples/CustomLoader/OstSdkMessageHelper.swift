/*
Copyright © 2019 OST.com Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
*/

import Foundation
import OstWalletSdk

@objc public class OstSdkMessageHelper: NSObject {
	
	static let shared = OstSdkMessageHelper()
	
	let DEFAULT_ERROR_MSG = "Something went wrong"
	let DEVICE_OUT_OF_SYNC = "DEVICE_OUT_OF_SYNC";
	let DEFAULT_CONTEXT = "__DEFAULT_CONTEXT";
	let developerMode = false
	
	let allMessages: [String: Any]
	override init() {
		allMessages = OstContentFetcher.getOstSdkMessages() ?? [:]
		super.init()
	}
	
	@objc public
	func getErrorMessage(for ostWorkflowContext: OstWorkflowContext,
						 andError error: OstError) -> String {
		
		let errMsg = _getErrorMessage(for: ostWorkflowContext, andError: error);
		return errMsg;
	}
	
	func _getErrorMessage(for ostWorkflowContext: OstWorkflowContext,
						  andError error: OstError) -> String {
		var errMsg: String? = nil
		
		var errorCode = OstErrorCodes.getStringErrorCode(errorCode:  error.messageTextCode)
		let workflowType = ostWorkflowContext.workflowType.getStringValue()
		
		if (error as? OstApiError)?.isDeviceTimeOutOfSync() ?? false {
			errorCode = DEVICE_OUT_OF_SYNC
			
			if nil != allMessages[workflowType] {
				errMsg = (allMessages[workflowType] as! [String: String])[ errorCode ];
			}
			
			if nil == errMsg {
				errMsg = (allMessages[DEFAULT_CONTEXT] as! [String: String])[ errorCode ];
			}
			
			if developerMode && nil != errMsg {
				if let internalId: String = (error as? OstApiError)?.getApiInternalId() {
					errMsg = errMsg! + "\n\n\(internalId)"
				}
			}
			return errMsg ?? DEFAULT_ERROR_MSG;
		}
		else if error.isApiError {
			if (error as? OstApiError)?.isApiSignerUnauthorized() ?? false {
				return "Device is not authorized. Please authorize device again."
			}
			
			if ( nil == errMsg ) {
				if let errorInfo = error.errorInfo,
					let errData = (errorInfo["err"] as? [String: Any])?["error_data"] as? [[String: Any]]{
					if (errData.count > 0) {
						let firstErrMsg = errData[0] as [String: Any];
						errMsg = (firstErrMsg["msg"] as? String) ?? DEFAULT_ERROR_MSG;
					}
				}
				
				if ( developerMode && nil != errMsg) {
					if let internalId: String = (error as? OstApiError)?.getApiInternalId() {
						errMsg = errMsg! + "\n\n\(internalId)"
					}
				}
				return errMsg ?? DEFAULT_ERROR_MSG
			}
		}
		
		if nil != allMessages[workflowType] {
			errMsg = ((allMessages[workflowType] as! [String: String])[ errorCode ]);
		}
		
		if nil == errMsg {
			errMsg = (allMessages[DEFAULT_CONTEXT] as? [String: String])?[ errorCode ];
		}
		
		if developerMode && nil != errMsg {
			errMsg = errMsg! + "\n\n (\(errorCode), \(error.internalCode))"
		}
		
		return errMsg ?? DEFAULT_ERROR_MSG
	}
	
	func getSuccessMessage(for workflowContext: OstWorkflowContext) -> String {
		let workflowType = workflowContext.workflowType
		let workflowTypeStringVal = workflowType.getStringValue()
		if let workflowDic = allMessages[workflowTypeStringVal] as? [String: Any]
			,let successMessage = workflowDic[workflowTypeStringVal] as? String {
			
			return successMessage
		}
		
		return "Workflow completed"
	}
}

extension OstWorkflowType {
  func getStringValue() -> String {
    switch self {
    case .activateUser:
      return "ACTIVATE_USER";
    case .addSession:
      return "ADD_SESSION"
    case .getDeviceMnemonics:
      return "GET_DEVICE_MNEMONICS"
    case .performQRAction:
      return "PERFORM_QR_ACTION"
    case .authorizeDeviceWithQRCode:
      return "AUTHORIZE_DEVICE_WITH_QR_CODE"
    case .authorizeDeviceWithMnemonics:
      return "AUTHORIZE_DEVICE_WITH_MNEMONICS"
    case .initiateDeviceRecovery:
      return "INITIATE_DEVICE_RECOVERY"
    case .abortDeviceRecovery:
      return "ABORT_DEVICE_RECOVERY"
    case .resetPin:
      return "RESET_PIN"
    case .logoutAllSessions:
      return "LOGOUT_ALL_SESSIONS"
    case .updateBiometricPreference:
      return "UPDATE_BIOMETRIC_PREFERENCE"
    case .executeTransaction:
      return "EXECUTE_TRANSACTION"
    default:
      return "ACTIVATE_USER"
    }
  }
}
