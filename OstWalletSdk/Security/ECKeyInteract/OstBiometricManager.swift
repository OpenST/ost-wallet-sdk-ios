/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstBiometricManager {
    
    private let userId: String
    private let keyManagareDelegate: OstKeyManagerDelegate
    init (userId: String,
          keyManagareDelegate: OstKeyManagerDelegate) {
        
        self.userId = userId
        self.keyManagareDelegate = keyManagareDelegate
    }
    
    func enableBiometric() throws {
        try keyManagareDelegate.setBiometricPreference(true)
    }
    
    func disableBiometric() throws {
        try keyManagareDelegate.setBiometricPreference(false)
    }
}
