/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class TransactionAPI: BaseAPI {
    class func getTransactionLedger(onSuccess: (([String: Any]?) -> Void)? = nil,
                                    onFailure: (([String: Any]?) -> Void)? = nil) {
        
        self.get(resource: "users/ledger",
                 params: nil,
                 onSuccess: onSuccess,
                 onFailure: onFailure)
    }
}

