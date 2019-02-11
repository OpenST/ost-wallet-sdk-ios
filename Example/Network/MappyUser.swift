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
    
    func createUser(params:[String: Any], success:@escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL
        post(params: params as [String : AnyObject], success: success, failuar: failuar)
    }
    
    func getUser(userId: String, success: @escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL + "/"+userId
        get(success: success, failuar: failuar)
    }
    
    func validateUser(params:[String: Any], success:@escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL + "/validate"
        post(params: params as [String : AnyObject], success: success, failuar: failuar)
    }
    
    func getAllUsers(success:@escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL
        get(success: success, failuar: failuar)
    }
    
    func createOstUser(for userId: String, success:@escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL + "/" + userId + "/ost-users"
        post(success: success, failuar: failuar)
    }
    
    func getOstUser(userId: String, success: @escaping (([String: Any]) -> Void), failuar:@escaping (([String: Any]?) -> Void)) {
        resourceURL = usersURL + "/" + userId + "/ost-users"
        get(success: success, failuar: failuar)
    }
}
