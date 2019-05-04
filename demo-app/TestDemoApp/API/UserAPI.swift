//
//  UserAPI.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 04/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class UserAPI: BaseAPI {
    
    class func getUsers(meta: [String: Any]? = nil,
                        onSuccess: (([String: Any]?) -> Void)? = nil,
                        onFailure: (([String: Any]?) -> Void)? = nil) {
        self.get(resource: "/users",
                 params: (meta as [String : AnyObject]?) ?? nil,
                 onSuccess: onSuccess,
                 onFailure: onFailure)
    }
}
