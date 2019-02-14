//
//  LoggedInUserInfo.swift
//  Shrine
//
//  Created by Rachin Kapoor on 11/02/19.
//  Copyright © 2019 Google. All rights reserved.
//

import Foundation

class CurrentUser: BaseModel {
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
    
  override init() {
    super.init();
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
  }
    
  func signUp(username:String , phonenumber:String, onComplete:@escaping ((Bool)->Void) ) {
    if( username.count < 4 || phonenumber.count < 10) {
        onComplete(false);
        return;
    }
  
    var params: [String: Any] = [:];
    params["username"] = username;
    params["mobile_number"] = phonenumber;
    params["create_ost_user"] = "true";
    
    self.post(resource: "/users", params: params as [String : AnyObject], onSuccess: { (appApiResponse: [String : Any]?) in
      self.appUserId = appApiResponse!["app_user_id"] as? String;
      self.ostUserId = appApiResponse!["user_id"] as? String;
      self.tokenId = appApiResponse!["token_id"] as? String;
      self.userPinSalt = appApiResponse!["user_pin_salt"] as? String;
      
      onComplete(true);
    }) { (failuarResponse) in
      onComplete(false);
    }
  }
  
  func login(username:String , phonenumber:String, onComplete:@escaping ((Bool)->Void) ) {
    if( username.count < 4 || phonenumber.count < 10) {
      onComplete(false);
      return;
    }
    
    var params: [String: Any] = [:];
    params["username"] = username;
    params["mobile_number"] = phonenumber;
    
    self.post(resource: "/users/validate", params: params as [String : AnyObject], onSuccess: { (appApiResponse: [String : Any]?) in
      let appUserId = appApiResponse!["_id"] as? String;
      self.getOstUser(appUserId:appUserId!, onComplete: onComplete);
      onComplete(true);
    }) { ([String : Any]?) in
      onComplete(false);
    }
    
  }
  
  func getOstUser(appUserId:String, onComplete:@escaping ((Bool)->Void)) {
    
    let params: [String: Any] = [:];
    
    self.get(resource: "/users/\(appUserId)/ost-users", params: params as [String : AnyObject], onSuccess: { (appApiResponse: [String : Any]?) in

      self.appUserId = appApiResponse!["app_user_id"] as? String;
      self.ostUserId = appApiResponse!["user_id"] as? String;
      self.tokenId = appApiResponse!["token_id"] as? String;
      self.userPinSalt = appApiResponse!["user_pin_salt"] as? String;

      onComplete(true);
    }, onFailuar: { ([String : Any]?) in
      onComplete(false);
    })
  }
}