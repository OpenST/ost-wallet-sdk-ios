/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import BigInt

class OstWorkflowValidator {
    private let userId: String
    private var currentUser: OstUser? {
        do {
            return try OstUser.getById(self.userId)
        }catch {
            return nil
        }
    }
    
    /// Initializer
    init(withUserId userId: String) {
        self.userId = userId
    }
    
    
}


