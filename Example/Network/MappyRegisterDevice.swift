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
    
    override var getBaseURL: String {
        return ""
    }
    
    override var getResource: String {
        return ""
    }
    
    func registerDevice(_ params: [String: AnyObject], success:@escaping (([String: Any]) -> Void), failuar:@escaping (() -> Void)) {
        
        post(params: params, success: success) { (failuarResponse) in
            failuar()
        }
    }
}
