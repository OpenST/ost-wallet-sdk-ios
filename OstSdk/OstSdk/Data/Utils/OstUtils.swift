//
//  OstUtils.swift
//  OstSdk
//
//  Created by aniket ayachit on 15/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstUtils {
    
    static func toString(_ val: Any?) -> String? {
        if val == nil {
            return nil
        }
        if (val is String){
            return (val as! String)
        }else if (val is Int){
            return String(val as! Int)
        }
        return nil
    }
}
