/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import Alamofire

class Logger {
    class func log(message: String? = nil, parameterToPrint: Any? = nil, function: String = #function) {
        #if DEBUG
        debugPrint()
        debugPrint("************************ START *********************************")
        debugPrint("function: \(function)")
        debugPrint("\(message ?? "")")
        debugPrint(parameterToPrint as AnyObject)
        debugPrint("************************* END *******************************")
        #endif
    }
}

extension Request {
    func debugLog() -> Self {
        #if DEBUG
        debugPrint()
        debugPrint("=======================================")
        debugPrint(self)
        debugPrint("=======================================")
        #endif
        return self
    }
}
