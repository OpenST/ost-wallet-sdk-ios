//
//  UserAPI.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 04/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class UserAPI: BaseAPI {
    
    class func signupUser(params: [String: Any],
                          onSuccess: (([String: Any]?) -> Void)? = nil,
                          onFailure: (([String: Any]?) -> Void)? = nil) {
        
        self.post(resource: "/signup",
                  params: params as [String : AnyObject]?,
                  onSuccess: { (apiParams) in
                    guard let data = apiParams?["data"] as? [String: Any] else {
                       onFailure?(apiParams)
                        return
                    }
                    let resultType = data["result_type"] as! String
                    guard let userData = data[resultType] as? [String: Any] else {
                        onFailure?(nil)
                        return
                    }
                    onSuccess?(userData)
                    
                    },
                  onFailure: onFailure)
    }
    
    class func loginUser(params: [String: Any]? = nil,
                         onSuccess: (([String: Any]?) -> Void)? = nil,
                         onFailure: (([String: Any]?) -> Void)? = nil) {
        self.post(resource: "/login",
                  params: params as [String : AnyObject]?,
                  onSuccess: { (apiParams) in
                    guard let data = apiParams?["data"] as? [String: Any] else {
                        onFailure?(apiParams)
                        return
                    }
                    let resultType = data["result_type"] as! String
                    guard let userData = data[resultType] as? [String: Any] else {
                        onFailure?(nil)
                        return
                    }
                    onSuccess?(userData)
        },
                  onFailure: onFailure)
    }
    
    class func getCurrentUser(onSuccess: (([String: Any]?) -> Void)? = nil,
                              onFailure: (([String: Any]?) -> Void)? = nil) {
        self.get(resource: "/users/current-user",
                  params: nil,
                  onSuccess: { (apiParams) in
                    guard let data = apiParams?["data"] as? [String: Any] else {
                        onFailure?(apiParams)
                        return
                    }
                    let resultType = data["result_type"] as! String
                    guard let userData = data[resultType] as? [String: Any] else {
                        onFailure?(nil)
                        return
                    }
                    onSuccess?(userData)
        },
                  onFailure: onFailure)
    }
    
    class func notifyUserActivated(onSuccess: (([String: Any]?) -> Void)? = nil,
                                   onFailure: (([String: Any]?) -> Void)? = nil) {
        self.post(resource: "/notify/user-activate",
                  params: nil,
                  onSuccess: { (apiParams) in
                    guard let data = apiParams?["data"] as? [String: Any] else {
                        onFailure?(nil)
                        return
                    }
                    let resultType = data["result_type"] as! String
                    guard let userData = data[resultType] as? [String: Any] else {
                        onFailure?(nil)
                        return
                    }
                    onSuccess?(userData)
        },
                  onFailure: onFailure)
    }
    
    class func getUserBalance(userId: String,
                              onSuccess: (([String: Any]?) -> Void)? = nil,
                              onFailure: (([String: Any]?) -> Void)? = nil) {
        
        self.get(resource: "/users/\(userId)/balance",
            params: nil,
            onSuccess: { (apiParams) in
                guard let data = apiParams?["data"] as? [String: Any] else {
                    onFailure?(nil)
                    return
                }
                let resultType = data["result_type"] as! String
                guard let balanceData = data[resultType] as? [String: Any] else {
                    onFailure?(nil)
                    return
                }
                
                if let pricePoint = data["price_point"] as? [String: Any] {
                    CurrentUserModel.getInstance.pricePoint = pricePoint
                }
                
                onSuccess?(balanceData)
        },
            onFailure: onFailure)
    }
    
    class func updateCrashlyticsPreference(userId: String,
                                           params: [String: Any]?,
                                           onSuccess: (([String: Any]?) -> Void)? = nil,
                                           onFailure: (([String: Any]?) -> Void)? = nil) {
        
        self.post(resource: "/users/\(userId)/set-preference",
            params: params as [String: AnyObject]?,
            onSuccess: { (apiParams) in
                guard let data = (apiParams?["data"] as? [String: Any]) else {
                    onFailure?(nil)
                    return
                }
                onSuccess?(data)
        },
            onFailure: onFailure)
    }
    
    class func getCrashlyticsPreference(userId: String,
                                        params: [String: Any]?,
                                        onSuccess: (([String: Any]?) -> Void)? = nil,
                                        onFailure: (([String: Any]?) -> Void)? = nil) {
        
        self.get(resource: "/users/\(userId)/get-preference",
            params: params as [String: AnyObject]?,
            onSuccess: { (apiParams) in
                guard let data = (apiParams?["data"] as? [String: Any]) else {
                    onFailure?(nil)
                    return
                }
                onSuccess?(data)
        },
            onFailure: onFailure)
    }
    
    class func getUserDetails(onSuccess: (([String: Any]?) -> Void)? = nil,
                              onFailure: (([String: Any]?) -> Void)? = nil) {
        self.get(resource: "/users/current-user",
                 params: nil,
                 onSuccess: { (apiParams) in
                    guard let data = apiParams?["data"] as? [String: Any] else {
                        onFailure?(nil)
                        return
                    }
                    let resultType = data["result_type"] as! String
                    guard let userData = data[resultType] as? [String: Any] else {
                        onFailure?(nil)
                        return
                    }
                    onSuccess?(userData)
        },
                 onFailure: onFailure)
    }
    
    class func getUsers(meta: [String: Any]? = nil,
                        onSuccess: (([String: Any]?) -> Void)? = nil,
                        onFailure: (([String: Any]?) -> Void)? = nil) {
        self.get(resource: "/users",
                 params: meta as [String : AnyObject]?,
                 onSuccess: onSuccess,
                 onFailure: onFailure)
    }
    
    class func getCurrentUserSalt(meta: [String: Any]? = nil,
                        onSuccess: ((String, [String: Any]?) -> Void)? = nil,
                        onFailure: (([String: Any]?) -> Void)? = nil) {
        self.get(resource: "/users/current-user-salt",
                 params: meta as [String : AnyObject]?,
                 onSuccess: { (apiResponse) in
                    guard let data = apiResponse?["data"] as? [String: Any] else {
                        var error:[String: Any] = apiResponse?["error"] as? [String: Any]  ?? [:];
                        error["display_message"] = "Something went wrong";
                        error["extra_info"] = "Api returned error.";
                        onFailure?( apiResponse?["error"] as? [String: Any] )
                        return
                    }
                    
                    guard let resultType = data["result_type"] as? String else {
                        var error:[String: Any] = [:];
                        error["display_message"] = "Something went wrong";
                        error["extra_info"] = "Api response is not as expected.";
                        onFailure?(error);
                        return;
                    }
                    
                    guard let result = data[ resultType ] as? [String: Any] else {
                        var error:[String: Any] = [:];
                        error["display_message"] = "Something went wrong";
                        error["extra_info"] = "Api response is not as expected.";
                        onFailure?(error);
                        return;
                    }
                    
                    guard let recoveryPinSalt = result["recovery_pin_salt"] as? String else {
                        var error:[String: Any] = [:];
                        error["display_message"] = "Something went wrong";
                        error["extra_info"] = "Api response is not as expected.";
                        onFailure?(error);
                        return;
                    }
                    
                    onSuccess?(recoveryPinSalt, data);
        },
                 onFailure: { (apiResponse) in
                    onFailure?( apiResponse?["error"] as? [String: Any] );
        });
    }
    
    class func logoutUser(onSuccess: (([String: Any]?) -> Void)? = nil,
                         onFailure: (([String: Any]?) -> Void)? = nil) {
        
        self.post(resource: "/users/logout", params: nil,
                  onSuccess: onSuccess, onFailure: onFailure)
    }
}
