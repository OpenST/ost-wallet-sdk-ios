//
//  MappyCreateUser.swift
//  Example
//
//  Created by aniket ayachit on 07/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class MappyUser: MappyAPIBase {
    
    var resourceURL: String = "/api/users"
    
    override init() { super.init() }

    override var getResource: String {
        return resourceURL
    }
    
    func createUser(success:@escaping (([String: Any]) -> Void), failuar:@escaping (() -> Void)) {
        let params = ["user_"]
    }
    
    func getUser(userId: String, success: @escaping (([String: Any]) -> Void), failuar:@escaping (() -> Void)) {
        resourceURL += "/"+userId
        get(success: success) { (failuarResponse) in
            failuar()
        }
    }
}
