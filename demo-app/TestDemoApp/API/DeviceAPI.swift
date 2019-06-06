/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class DeviceAPI: BaseAPI {
    
    class func registerDevice(params: [String: Any],
                              onSuccess: (([String: Any]?) -> Void)? = nil,
                              onFailure: (([String: Any]?) -> Void)? = nil) {
        
        self.post(resource: "/devices",
                  params: params as [String: AnyObject],
                  onSuccess: { (apiParams) in
                    guard let data = apiParams?["data"] as? [String: Any] else {
                        onFailure?(apiParams)
                        var msg: String = "Something went wrong"
                        if let err = apiParams?["err"] as? [String: Any] {
                            msg = err["msg"] as? String ?? msg
                        }else {
                            msg = apiParams?["msg"] as? String ?? msg
                        }
                        OstErroNotification.showNotification(withMessage: msg)
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
    
    class func getDevices(meta: [String: Any]? = nil,
                          onSuccess: (([String: Any]?) -> Void)? = nil,
                          onFailure: (([String: Any]?) -> Void)? = nil) {
        
        self.get(resource: "/devices",
                 params: nil,
                 onSuccess: { (apiParams) in
                    guard let data = apiParams?["data"] as? [String: Any] else {
                        onFailure?(nil)
                        return
                    }
                    let resultType = data["result_type"] as! String
                    
                    onSuccess?(data)
        },
                 onFailure: onFailure)
    }
    
}


