//
//  SharedDatabase.swift
//  Example
//
//  Created by aniket ayachit on 08/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class SharedDatabase {
    
    var userEntities: [String: [String: Any]] = [:]
    
    static let sharedInstance = SharedDatabase()
    private init() {}
    
    //MARK: - User Entity
    func insertUser(_ user: [String: Any]) {
        let id = user["mobile_number"] as! String
        userEntities[id] = user
    }
    func insertUsers(_ users: [[String: Any]]) {
        for user in users {
            insertUser(user)
        }
    }
    
    func getUser(forMobileNumber mobileNumer: String) -> [String: Any]? {
        return userEntities[mobileNumer]
    }
    func getUserList() -> [[String: Any]] {
        return Array(userEntities.values)
    }
}
