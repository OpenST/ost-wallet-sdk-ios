//
//  Users.swift
//  Demo-App
//
//  Created by Rachin Kapoor on 12/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire
import CryptoSwift
import OstSdk;

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
    
    let tokenHolderAddress:String? = userData["token_holder_address"] as! String?;
    user!.tokenHolderAddress = tokenHolderAddress;
    if ( tokenHolderAddress != nil ) {
      self.tokenHolderToUserMap[ tokenHolderAddress! ] = user!;
    }
    
    var userDescription:String? = userData["description"] as! String?;
    if ( (userDescription == nil || userDescription!.isEmpty)) {
        userDescription = username + " have not provided their bio.";
    }
    
    if ( ostUserId == nil ) {
        userDescription = userDescription! + "\n" + username + " have not setup their wallet.";
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
  
  
  let id:String;
  var ostUserId:String?;
  let username:String;
  let mobileNumber:String;
  var description:String?;
  var tokenHolderAddress:String?;
  var userImages: [CGFloat:UIImage];
  
  init(id:String, mobileNumber:String, username:String, imageSizes:[CGFloat] ){
    self.id = id;
    self.username = username;
    self.mobileNumber = mobileNumber;
    self.userImages = [:];
    
    var _imageSize = imageSizes;
    if (_imageSize.count < 1) {
      _imageSize.append(600);
    }
    
    for sizeCnt in 0..<_imageSize.count {
      let imgSize = _imageSize[sizeCnt];
        self.userImages[imgSize] = User.generateImage(imageSeed:(mobileNumber+username), size:imgSize);
    }
    
    
  }
  
  
  static func generateImage(imageSeed:String, size:CGFloat) -> UIImage {
    
    var imagHash = Data(imageSeed.sha1().utf8);
    print("imageSeed", imageSeed);
    
    
    
    
    let generator = IconGenerator(size: size, hash: imagHash);
    return UIImage(cgImage: generator.render()!);
  }
  
}