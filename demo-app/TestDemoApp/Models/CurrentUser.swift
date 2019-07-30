/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation;
import OstWalletSdk
class CurrentUser: BaseModel, OWFlowInterruptedDelegate, OWFlowCompleteDelegate, OWPassphrasePrefixDelegate {

  static var sharedInstance:CurrentUser?;
  
  class func getInstance() -> CurrentUser {
    if (sharedInstance != nil) {
      return sharedInstance!;
    }
  
    sharedInstance = CurrentUser();
    return sharedInstance!;
  }

    var tokenId:String?;
    var appUserId:String?;
    var ostUserId:String?;
    var skdUser:String?;
    var userPinSalt: String?;
    var userDevice: OstDevice?;
    var ostUser: OstUser?;
    var currentDeviceAddress: String?
    var userName: String? = ""
    var phoneNumber: String? = ""
    var currentUserData: [String: Any]?
  
  override init() {
    self.tokenId = nil;
    self.appUserId = nil;
    self.ostUserId = nil;
    self.skdUser = nil;
    self.userPinSalt = nil;
  }
  
  func logout() {
    self.tokenId = nil;
    self.appUserId = nil;
    self.ostUserId = nil;
    self.skdUser = nil;
    self.userPinSalt = nil;
    self.currentUserData = nil
  }
    

  func signUp(username:String , phonenumber:String, userDescription:String, onSuccess: @escaping ((OstUser, OstDevice) -> Void), onComplete:@escaping ((Bool)->Void) ) {
    
    var params: [String: Any] = [:];
    params["username"] = username;
    params["password"] = phonenumber;
    
    UserAPI.signupUser(params: params, onSuccess: { (appApiResponse) in
        self.appUserId = ConversionHelper.toString(appApiResponse!["app_user_id"])
        self.ostUserId = ConversionHelper.toString(appApiResponse!["user_id"])
        self.tokenId = ConversionHelper.toString(appApiResponse!["token_id"])
        self.userPinSalt = ConversionHelper.toString(appApiResponse!["user_pin_salt"])
        self.setupDevice(onSuccess: onSuccess, onComplete: onComplete);

    }) { (apiError) in
        onComplete(false);
    }    
    return;
    if( username.count < 4 || phonenumber.count < 10) {
        onComplete(false);
        return;
    }
    
    self.userName = username
    self.phoneNumber = phonenumber
//    var params: [String: Any] = [:];
    params["username"] = username;
    params["mobile_number"] = phonenumber;
    params["description"] = userDescription;
    params["create_ost_user"] = "true";
    
    self.post(resource: "/users",
              params: params as [String : AnyObject],
              onSuccess: { (appApiResponse: [String : Any]?) in
                
        self.userName = username
      self.appUserId = appApiResponse!["app_user_id"] as? String;
      self.ostUserId = appApiResponse!["user_id"] as? String;
      self.tokenId = appApiResponse!["token_id"] as? String;
      self.userPinSalt = appApiResponse!["user_pin_salt"] as? String;
        self.currentUserData = appApiResponse!
      
      self.setupDevice(onSuccess: onSuccess, onComplete: onComplete);
    }) { (failureResponse) in
      onComplete(false);
    }
  }
  

  func login(username:String , phonenumber:String, onSuccess: @escaping ((OstUser, OstDevice) -> Void), onComplete:@escaping ((Bool)->Void) ) {
    
    var params: [String: Any] = [:];
    params["username"] = username;
    params["password"] = phonenumber;
    
    UserAPI.loginUser(params: params, onSuccess: { (apiResponse) in
        self.appUserId = ConversionHelper.toString(apiResponse!["app_user_id"])
        self.ostUserId = ConversionHelper.toString(apiResponse!["user_id"])
        self.tokenId = ConversionHelper.toString(apiResponse!["token_id"])
        self.userPinSalt = ConversionHelper.toString(apiResponse!["user_pin_salt"])
        self.setupDevice(onSuccess: onSuccess, onComplete: onComplete);
        
    }) { (apiError) in
        onComplete(false);
    }
    
    return
    
    if( username.count < 4 || phonenumber.count < 10) {
      onComplete(false);
      return;
    }
    self.userName = username
    self.phoneNumber = phonenumber
    
//    var params: [String: Any] = [:];
    params["username"] = username;
    params["mobile_number"] = phonenumber;
    
    self.post(resource: "/users/validate",
              params: params as [String : AnyObject],
              onSuccess: { (appApiResponse: [String : Any]?) in
                
        self.userName = username
        self.phoneNumber = phonenumber
        self.appUserId = appApiResponse!["app_user_id"] as? String;
        self.ostUserId = appApiResponse!["user_id"] as? String;
        self.tokenId = appApiResponse!["token_id"] as? String;
        self.userPinSalt = appApiResponse!["user_pin_salt"] as? String;
        self.currentUserData = appApiResponse!
        
        self.setupDevice(onSuccess: onSuccess, onComplete: onComplete);
    }, onFailure: { (failureResponse) in
      onComplete(false);
    })
  }
  
  func getOstUser(appUserId:String,
                  onSuccess: @escaping ((OstUser, OstDevice) -> Void),
                  onComplete:@escaping ((Bool)->Void)) {
    
    let params: [String: Any] = [:];
    
    self.get(resource: "/users/\(appUserId)/ost-users",
             params: params as [String : AnyObject],
             onSuccess: { (appApiResponse: [String : Any]?) in

      self.appUserId = appApiResponse!["app_user_id"] as? String;
      self.ostUserId = appApiResponse!["user_id"] as? String;
      self.tokenId = appApiResponse!["token_id"] as? String;
      self.userPinSalt = appApiResponse!["user_pin_salt"] as? String;
      
      self.setupDevice(onSuccess: onSuccess, onComplete: onComplete);
    }, onFailure: { ([String : Any]?) in
      onComplete(false);
    })
  }
  
  //
    var setupDeviceOnSuccess: ((OstUser, OstDevice) -> Void)?
    var setupDeviceOnComplete: ((Bool)->Void)?
  func setupDevice(onSuccess: @escaping ((OstUser, OstDevice) -> Void), onComplete:@escaping ((Bool)->Void)) {
    
    setupDeviceOnSuccess = onSuccess
    setupDeviceOnComplete = onComplete
    
    let ostSdkInteract = OstSdkInteractOld();
    ostSdkInteract.addEventListner { (eventData:[String : Any]) in
      //self.onComplete = onComplete
      let eventType:OstSdkInteractOld.WorkflowEventType = eventData["eventType"] as! OstSdkInteractOld.WorkflowEventType;
      if ( OstSdkInteractOld.WorkflowEventType.flowComplete == eventType ) {
        let ostContextEntity: OstContextEntity = eventData["ostContextEntity"] as! OstContextEntity
        let workflowContext: OstWorkflowContext = eventData["workflowContext"] as! OstWorkflowContext
        if ( workflowContext.workflowType == OstWorkflowType.setupDevice ) {
          let userDevice = ostContextEntity.entity as! OstDevice;
          self.currentDeviceAddress = userDevice.address;
          self.userDevice = userDevice;

            self.ostUser = OstWalletSdk.getUser(self.ostUserId!);
            print("onSuccess triggered for ", eventType);
            onSuccess(self.ostUser!, self.userDevice!);
        }
        //Callback onComplete with true.
        onComplete(true);
      } else {
        print("Received", eventType);
        onComplete(false);
      }
    }
    
    let workflowCallback = OstSdkInteract.getInstance.getWorkflowCallback(forUserId: self.ostUserId!)
    OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowCallback.workflowId, listner: self)
    
    OstWalletSdk.setupDevice(userId: self.ostUserId!,
                             tokenId: self.tokenId!,
                             forceSync:true,
                             delegate: workflowCallback);
  }
    
    
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        setupDeviceOnComplete?(true);
    }
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if ( workflowContext.workflowType == OstWorkflowType.setupDevice ) {
            let userDevice = contextEntity.entity as! OstDevice;
            self.currentDeviceAddress = userDevice.address;
            self.userDevice = userDevice;
            self.ostUser = OstWalletSdk.getUser(self.ostUserId!);
            print("onSuccess triggered for ", workflowContext.workflowType);
            setupDeviceOnSuccess?(self.ostUser!, self.userDevice!)
        }
        //Callback onComplete with true.
        setupDeviceOnComplete?(true);
    }
    
    func getPassphrase(ostUserId: String, ostPassphrasePrefixAcceptDelegate: OWPassphrasePrefixAcceptDelegate) {
        ostPassphrasePrefixAcceptDelegate.setPassphrase(ostUserId: ostUserId, passphrase: self.userPinSalt!);
    }
}
