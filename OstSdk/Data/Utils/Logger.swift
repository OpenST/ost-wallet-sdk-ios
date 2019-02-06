//
//  Log.swift
//  OstSdk
//
//  Created by aniket ayachit on 06/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import Alamofire

class Logger {
    
    var intFor : Int
    
    init() {
        intFor = 42
    }
    
    func DLog(message: String? = nil, parameterToPrit: Any, function: String = #function) {
        #if DEBUG
            debugPrint("************************ START *********************************")
            debugPrint("function: \(function)")
            if (message != nil) {
                debugPrint("message: \(message!)")
            }
            debugPrint(parameterToPrit)
            debugPrint("************************* END *******************************")
        #endif
    }
}

extension Request {
    public func debugLog() -> Self {
        #if DEBUG
        debugPrint("=======================================")
        debugPrint(self)
        debugPrint("=======================================")
        #endif
        return self
    }
}
