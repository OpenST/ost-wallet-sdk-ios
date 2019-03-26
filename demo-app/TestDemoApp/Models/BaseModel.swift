//
//  BaseModel.swift
//  Demo-App
//
//  Created by Rachin Kapoor on 12/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire

class BaseModel {
    
    static let MAPPY_APP_SERVER_URL = Bundle.main.infoDictionary!["MAPPY_APP_SERVER_URL"] as! String
    static let KIT_API_ENDPOINT = Bundle.main.infoDictionary!["KIT_API_ENDPOINT"] as! String
    
  static let TOKEN_ID = "58";
  func post(resource:String, params: [String: AnyObject]?,
            onSuccess: (([String: Any]?) -> Void)?,
            onFailure: (([String: Any]?) -> Void)?) {
        
    let url = BaseModel.MAPPY_APP_SERVER_URL + resource
    
    let dataRequest = Alamofire.request(url, method: .post, parameters: params)
    dataRequest.responseJSON { (httpResonse) in
      if (httpResonse.result.isSuccess && httpResonse.response!.statusCode >= 200 && httpResonse.response!.statusCode < 300) {
        // Call Success
        onSuccess?(httpResonse.result.value as? [String: Any])
      } else if (httpResonse.result.isSuccess && httpResonse.response!.statusCode == 401) {
        // Unauthorized.
        
      } else {
        onFailure?(httpResonse.result.value as? [String: Any])
      }
    }
  }
  
  func get(resource:String, params: [String: AnyObject]?,
           onSuccess: (([String: Any]?) -> Void)?,
           onFailure: (([String: Any]?) -> Void)?) {
    
    let url = BaseModel.MAPPY_APP_SERVER_URL + resource
    
    let dataRequest = Alamofire.request(url, method: .get, parameters: params)
    dataRequest.responseJSON { (httpResonse) in
      if (httpResonse.result.isSuccess && httpResonse.response!.statusCode >= 200 && httpResonse.response!.statusCode < 300) {
        // Call Success
        onSuccess?(httpResonse.result.value as? [String: Any])
      } else if (httpResonse.result.isSuccess && httpResonse.response!.statusCode >= 400 && httpResonse.response!.statusCode < 500) {
        // Unauthorized.
        
      } else {
        onFailure?(httpResonse.result.value as? [String: Any])
      }
    }
  }
}
