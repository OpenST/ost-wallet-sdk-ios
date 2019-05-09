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
    var userDetails: [String: Any]? = nil
    
    var setupDeviceOnSuccess: ((OstUser, OstDevice) -> Void)?
    var setupDeviceOnComplete: ((Bool)->Void)?
    
    //MARK: - API
    func setupDevice(onSuccess: @escaping ((OstUser, OstDevice) -> Void), onComplete:@escaping ((Bool)->Void)) {
        
        setupDeviceOnSuccess = onSuccess
        setupDeviceOnComplete = onComplete
        
        let workflowCallback = OstSdkInteract.getInstance.getWorkflowCallback(forUserId: CurrentUserModel.getInstance.ostUserId!)
        OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowCallback.workflowId, listner: self)
        
        OstWalletSdk.setupDevice(userId: self.ostUserId!,
                                 tokenId: self.tokenId!,
                                 forceSync:true,
                                 delegate: workflowCallback);
    }
    
    func login(username:String ,
               phonenumber:String,
               onSuccess: @escaping ((OstUser, OstDevice) -> Void),
               onComplete:@escaping ((Bool)->Void) ) {
        
        var params: [String: Any] = [:];
        params["username"] = username;
        params["password"] = phonenumber;
        
        UserAPI.loginUser(params: params,
                          onSuccess: { (apiResponse) in
                            CurrentUserModel.getInstance.userDetails = apiResponse
                            self.setupDevice(onSuccess: onSuccess, onComplete: onComplete);
        }) { (apiError) in
            onComplete(false)
        }
    }
    
    func signUp(username:String ,
                phonenumber:String,
                userDescription:String,
                onSuccess: @escaping ((OstUser, OstDevice) -> Void),
                onComplete:@escaping ((Bool)->Void) ) {
        
        var params: [String: Any] = [:];
        params["username"] = username;
        params["password"] = phonenumber;
        
        UserAPI.signupUser(params: params,
                           onSuccess: { (apiResponse) in
                            CurrentUserModel.getInstance.userDetails = apiResponse
                            self.setupDevice(onSuccess: onSuccess, onComplete: onComplete);
        }) { (apiError) in
            onComplete(false)
        }
    }
    
    
    //MARK: - OstWorkflow Delegate
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        setupDeviceOnComplete?(true);
    }
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if ( workflowContext.workflowType == OstWorkflowType.setupDevice ) {
            print("onSuccess triggered for ", workflowContext.workflowType);
            setupDeviceOnSuccess?(self.ostUser!, self.userDevice!)
        }
        //Callback onComplete with true.
        setupDeviceOnComplete?(true);
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
    
    var userDevice: OstDevice? {
        if let userId = ostUserId {
            let ostUser = OstWalletSdk.getUser(userId)
            return ostUser?.getCurrentDevice()
        }
        return nil
    }
    
    var status: String? {
        return userDetails?["status"] as? String ?? nil
    }
}
