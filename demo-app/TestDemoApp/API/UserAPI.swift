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
    
    class func loginUser(params: [String: Any],
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
    
    class func getBalance(onSuccess: (([String: Any]?) -> Void)? = nil,
                          onFailure: (([String: Any]?) -> Void)? = nil) {
        
        self.get(resource: "/users/\(CurrentUserModel.getInstance.appUserId!)/balance",
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
}
