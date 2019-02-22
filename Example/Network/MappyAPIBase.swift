//
//  OstMappyAPIBase.swift
//  Example
//
//  Created by aniket ayachit on 07/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk

class MappyAPIBase: OstAPIBase {
    init() { super.init() }
    
//    override var getBaseURL: String {
//        return "http://172.16.0.108:4040"
//    }
    
    override var getBaseURL: String {
        return "http://localhost:4040"
    }
    
    var resourceURL: String = ""
    
    override var getResource: String {
        return resourceURL
    }
    
    open override func isResponseSuccess(_ response: Any?) -> Bool {
        return true
    }
}
