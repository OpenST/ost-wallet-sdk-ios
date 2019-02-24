//
//  MappyRegisterDevice.swift
//  Example
//
//  Created by aniket ayachit on 07/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class MappyRegisterDevice: MappyAPIBase {
    override init() { }
    
    let registerDeviceURL = "/api/users"
    
    func registerDevice(_ params: [String: AnyObject], forUserId userId: String, onSuccess:@escaping (([String: Any]?) -> Void), onFailure:@escaping (([String: Any]?) -> Void)) {
        resourceURL = registerDeviceURL + "/" + userId + "/devices"
        post(params: params, onSuccess: onSuccess, onFailure: onFailure)
    }
}
