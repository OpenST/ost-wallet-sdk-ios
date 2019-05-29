/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class CurrentUserModel: OstBaseModel, OstFlowInterruptedDelegate, OstFlowCompleteDelegate, OstPassphrasePrefixDelegate {
    static let getInstance = CurrentUserModel()
    override init() {
        super.init()
    }
    //MARK: - Variables
    private var userDetails: [String: Any]? {
        didSet {
            userBalanceDetails = nil
            if nil == userDetails {
                isUserLoggedIn = false
            }else {
                isUserLoggedIn = true
            }
        }
    }
    var userBalanceDetails: [String: Any]? = nil
    var pricePoint: [String: Any]? = nil
    var isUserLoggedIn: Bool = false
    
    var setupDeviceOnSuccess: ((OstUser, OstDevice) -> Void)?
    var setupDeviceOnFailure: (([String: Any]?)->Void)?
    
    func logoutUser() {
        self.userDetails = nil
    }
    
    func logout() {
        UserAPI.logoutUser()
        logoutUser() 
    }
    
    //MARK: - API
    func setupDevice(onSuccess: @escaping ((OstUser, OstDevice) -> Void), onFailure:@escaping (([String: Any]?)->Void)) {
        
        setupDeviceOnSuccess = onSuccess
        setupDeviceOnFailure = onFailure
        
        let workflowCallback = OstSdkInteract.getInstance.getWorkflowCallback(forUserId: CurrentUserModel.getInstance.ostUserId!)
        OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowCallback.workflowId, listner: self)
        
        OstWalletSdk.setupDevice(userId: self.ostUserId!,
                                 tokenId: self.tokenId!,
                                 forceSync:true,
                                 delegate: workflowCallback);
    }
    
    func login(username:String,
               phonenumber:String,
               onSuccess: @escaping ((OstUser, OstDevice) -> Void),
               onFailure:@escaping (([String: Any]?)->Void) ) {
        
        var params: [String: Any] = [:]
        params["username"] = username;
        params["password"] = phonenumber;
        
        UserAPI.loginUser(params: params,
                          onSuccess: { (apiResponse) in
                            CurrentUserModel.getInstance.userDetails = apiResponse
                            
                            self.setupDevice(onSuccess: onSuccess, onFailure: onFailure);
        }) { (apiError) in
            let msg = (apiError?["msg"] as? String) ?? "Login failed due to unknown reason"
            OstErroNotification.showNotification(withMessage: msg)
            onFailure(apiError)
        }
    }
    
    func signUp(username:String ,
                phonenumber:String,
                onSuccess: @escaping ((OstUser, OstDevice) -> Void),
                onFailure:@escaping (([String: Any]?)->Void) ) {
        
        var params: [String: Any] = [:];
        params["username"] = username;
        params["password"] = phonenumber;
        
        UserAPI.signupUser(params: params,
                           onSuccess: { (apiResponse) in
                            CurrentUserModel.getInstance.userDetails = apiResponse
                            self.setupDevice(onSuccess: onSuccess, onFailure: onFailure);
        }) { (apiError) in
            
            let msg = (apiError?["msg"] as? String) ?? "Signup failed due to unknown reason"
            OstErroNotification.showNotification(withMessage: msg)
            onFailure(apiError)
        }
    }
    
    func getCurrentUser(onSuccess: @escaping ((OstUser, OstDevice) -> Void),
                        onFailure:@escaping (([String: Any]?)->Void)) {
        
        UserAPI.getCurrentUser(onSuccess: {[weak self] (apiResponse) in
            
            CurrentUserModel.getInstance.userDetails = apiResponse
            self?.setupDevice(onSuccess: onSuccess, onFailure: onFailure);
        }) {(apiResponse) in
            onFailure(apiResponse)
        }
    }
    
   
    
    
    //MARK: - OstWorkflow Delegate
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        setupDeviceOnFailure?(error.errorInfo);
    }
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
        if ( workflowContext.workflowType == OstWorkflowType.setupDevice ) {
            print("onSuccess triggered for ", workflowContext.workflowType);
           
                setupDeviceOnSuccess?(self.ostUser!, self.currentDevice!)
           
        }else {
             setupDeviceOnFailure?(nil);
        }
    }
    
    func getPassphrase(ostUserId: String, ostPassphrasePrefixAcceptDelegate: OstPassphrasePrefixAcceptDelegate) {
        if ( nil == self.ostUserId || self.ostUserId!.compare(ostUserId) != .orderedSame ) {
            ostPassphrasePrefixAcceptDelegate.cancelFlow();
            return;
        }
        
        if ( nil == self.userPinSalt ) {
            ostPassphrasePrefixAcceptDelegate.cancelFlow();
            return;
        }
        ///TODO - Move this to other function.
        ///
        let userPinSalt = self.userPinSalt!;
        ostPassphrasePrefixAcceptDelegate.setPassphrase(ostUserId: self.ostUserId!, passphrase: userPinSalt);
    }

}

extension CurrentUserModel {
    var ostUserId: String? {
        let userId = userDetails?["user_id"]
        return ConversionHelper.toString(userId)
    }
    
    var userName: String? {
        return (userDetails?["username"] as? String) ?? nil
    }
    
    var tokenId: String? {
        let tokenId = userDetails?["token_id"]
        return ConversionHelper.toString(tokenId)
    }
    
    var appUserId: String? {
        let appUserId = userDetails?["app_user_id"]
        return ConversionHelper.toString(appUserId)
    }
    
    var tokenHolderAddress: String? {
        if let userId = ostUserId {
            let ostUser = OstWalletSdk.getUser(userId)
            return ostUser?.tokenHolderAddress
        }
        return nil
    }
    
    var deviceManagerAddress: String? {
        if let userId = ostUserId {
            let ostUser = OstWalletSdk.getUser(userId)
            return ostUser?.deviceManagerAddress
        }
        return nil
    }
    
    var userPinSalt: String? {
        return userDetails?["user_pin_salt"] as? String ?? nil
    }
    
    var ostUser: OstUser? {
        if let userId = ostUserId {
            return OstWalletSdk.getUser(userId)
        }
        return nil
    }
    
    var currentDevice: OstDevice? {
        if let userId = ostUserId {
            let ostUser = OstWalletSdk.getUser(userId)
            return ostUser?.getCurrentDevice()
        }
        return nil
    }
    
    var status: String? {
        return userDetails?["status"] as? String ?? nil
    }
    
    var ostUserStatus: String? {
        if let user = ostUser {
            return user.status
        }
        return nil
    }
    
    var balance: String {
        if let availabelBalance = userBalanceDetails?["available_balance"] {
            let amountVal = ConversionHelper.toString(availabelBalance)!.toRedableFormat()
            return amountVal.toDisplayTxValue()
        }
        return ""
    }
    
    var isCurrentDeviceStatusAuthorizing: Bool {
        if let currentDevice = self.currentDevice,
            let status = currentDevice.status {
            
            if status.caseInsensitiveCompare(ManageDeviceViewController.DeviceStatus.authorizing.rawValue) == .orderedSame{
                return true
            }
        }
        return false
    }

    var isCurrentDeviceStatusAuthrozied: Bool {
        if let currentDevice = self.currentDevice,
            let status = currentDevice.status {
            
            if status.caseInsensitiveCompare(ManageDeviceViewController.DeviceStatus.authorized.rawValue) == .orderedSame{
                return true
            }
        }
        return false
    }
    
    var isCurrentDeviceStatusRegistered: Bool {
        if let currentDevice = self.currentDevice,
            let status = currentDevice.status {
            
            if status.caseInsensitiveCompare(ManageDeviceViewController.DeviceStatus.registered.rawValue) == .orderedSame{
                return true
            }
        }
        return false
    }
    
    func showTokenHolderInView() {
        
        let webView = WKWebViewController()
        let currentEconomy = CurrentEconomy.getInstance
        
        let tokenHoderURL: String = "\(currentEconomy.viewEndPoint!)token/th-\(currentEconomy.auxiliaryChainId!)-\(currentEconomy.utilityBrandedToken!)-\(tokenHolderAddress!)"
        webView.title = "OST View"
        webView.urlString = tokenHoderURL
        
        webView.showVC()
    }
}

//MARK: - Price Point
extension CurrentUserModel {
    var getUSDValue: Double? {
        guard let pricePoint = self.pricePoint else {
            return nil
        }
       
        if let tokenId = self.tokenId,
            let ostToken: OstToken = OstWalletSdk.getToken(tokenId) {
            
            let baseCurrency = ostToken.baseToken
            if let currencyPricePoint = pricePoint[baseCurrency] as? [String: Any],
                let strValue = ConversionHelper.toString(currencyPricePoint["USD"]) {
                return Double(strValue)
            }
        }
        return nil
    }
    
    func toUSD(value: String) -> String? {
        guard let usdValue = getUSDValue,
            let doubleValue = Double(value) else {
                return nil
        }
        
        guard let token = OstWalletSdk.getToken(CurrentEconomy.getInstance.tokenId!),
            let conversionFactor = token.conversionFactor,
            let doubleConversionFactor = Double(conversionFactor) else {
                
                return nil
        }
        
        let btToOstVal = (doubleValue/doubleConversionFactor)
        
        return String(usdValue * btToOstVal)
    }
}
