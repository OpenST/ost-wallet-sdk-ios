//
//  MappyCreateUser.swift
//  Example
//
//  Created by aniket ayachit on 07/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class MappyUser: MappyAPIBase {
    
    let usersURL = "/api/users"
    
    override init() { super.init() }
    
    func createUser(params:[String: Any], onSuccess:@escaping (([String: Any]?) -> Void), onFailure:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL
        post(params: params as [String : AnyObject], onSuccess: onSuccess, onFailure: onFailure)
    }
    
    func getUser(userId: String, onSuccess: @escaping (([String: Any]?) -> Void), onFailure:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL + "/"+userId
        get(onSuccess: onSuccess, onFailure: onFailure)
    }
    
    func validateUser(params:[String: Any], onSuccess:@escaping (([String: Any]?) -> Void), onFailure:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL + "/validate"
        post(params: params as [String : AnyObject], onSuccess: onSuccess , onFailure: onFailure)
    }
    
    func getAllUsers(onSuccess:@escaping (([String: Any]?) -> Void), onFailure:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL
        get(onSuccess: onSuccess , onFailure: onFailure)
    }
    
    func createOstUser(for userId: String, onSuccess:@escaping (([String: Any]?) -> Void), onFailure:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL + "/" + userId + "/ost-users"
        post(onSuccess: onSuccess , onFailure: onFailure)
    }
    
    func getOstUser(userId: String, onSuccess: @escaping (([String: Any]?) -> Void), onFailure:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL + "/" + userId + "/ost-users"
        get(onSuccess: onSuccess , onFailure: onFailure)
    }
}
