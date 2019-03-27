/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import Alamofire
import CryptoSwift
import OstWalletSdk

class Users:BaseModel {
  var users: Array<User>;
  var idToUserMap: [String:User];
  var ostUserIdToUserMap: [String:User];
  var tokenHolderToUserMap: [String:User];
  static var imageSizes:[CGFloat] = [];
  
  static var sharedInstance:Users?;
  static func getInstance() -> Users {
    if ( sharedInstance == nil ) {
      sharedInstance = Users();
    }
    return sharedInstance!;
  }
  
  override init() {
    self.users = [];
    self.idToUserMap = [:];
    self.ostUserIdToUserMap = [:];
    self.tokenHolderToUserMap = [:];
  }
  
  func getUsers(onComplete:@escaping ((Array<User>)->Void), onError:@escaping (() -> Void)) {
    
    let params: [String: Any] = [:];
    self.get(resource: "/users", params: params as [String : AnyObject], onSuccess: { (appApiResponse: [String : Any]?) in
      
      let userData = (appApiResponse!["users"] as! Array<[String: Any]>)
      for cnt in 0..<userData.count {
        let currUserData = userData[cnt];
        self.addUserData( userData: currUserData );
      }
      onComplete(self.users);
    }) { ([String : Any]?) in
      onError();
    }

  }
  
  func addUserData(userData:[String: Any]) {
    let id = userData["_id"] as! String;
    let username = userData["username"] as! String;
    let mobileNumber = userData["mobile_number"] as! String;
    var user = getUserById(id:id);
    if ( user == nil ) {
      user = User(id:id, mobileNumber:mobileNumber, username:username, imageSizes: Users.imageSizes);
      self.idToUserMap[ id ] = user!;
      self.users.append(user!);
    }
    
    let ostUserId:String? = userData["ost_user_id"] as! String?;
    user!.ostUserId = ostUserId;
    if ( ostUserId != nil ) {
      self.ostUserIdToUserMap[ ostUserId! ] = user!;
    }
    
    let tokenHolderAddress:String? = userData["token_holder_address"] as? String? ?? nil;
    user!.tokenHolderAddress = tokenHolderAddress;
    if ( tokenHolderAddress != nil ) {
      self.tokenHolderToUserMap[ tokenHolderAddress! ] = user!;
    }
    
    var userDescription:String? = userData["description"] as! String?;
    if ( (userDescription == nil || userDescription!.isEmpty)) {
        userDescription = username + " have not provided their bio.";
    }
    
    if ( tokenHolderAddress == nil ) {
        userDescription = userDescription! + "\n" + username + " have not setup their wallet.";
    }
    
    let userDisplayName:String? = userData["user_display_name"] as! String?;
    if ( userDisplayName == nil ) {
        user?.displayName = user!.username;
    } else {
        user?.displayName = userDisplayName!;
    }
    
    user!.description = userDescription;
  }
  
  
  
  
  func getUserById(id:String) -> User? {
    return self.idToUserMap[ id ];
  }
  
  func getUserByOstId(ostUserId:String) -> User? {
    return self.ostUserIdToUserMap[ ostUserId ];
  }
  
  func getUserByTokenHolderAddress(tokenHolderAddress:String) -> User? {
    return self.tokenHolderToUserMap[ tokenHolderAddress ];
  }
}

class User {
  static var imageSize = CGFloat(128);
  
      let id:String;
      var ostUserId:String?;
      let username:String;
      var displayName:String?
      let mobileNumber:String;
      var description:String?;
      var tokenHolderAddress:String?;
      var userImage: CGImage;
  
  init(id:String, mobileNumber:String, username:String, imageSizes:[CGFloat] ){
    self.id = id;
    self.username = username;
    self.mobileNumber = mobileNumber;
    
    var _imageSize = imageSizes;
    if (_imageSize.count < 1) {
      _imageSize.append(600);
    }
    self.userImage = User.generateImage(imageSeed:(id), size: User.imageSize);
    
  }
  
  
  static func generateImage(imageSeed:String, size:CGFloat) -> CGImage {
    
    let imagHash = imageSeed.sha1().data(using: .ascii);
    
    let generator = IconGenerator(size: size, hash: imagHash!);
    return generator.render()!;
  }
  
}
