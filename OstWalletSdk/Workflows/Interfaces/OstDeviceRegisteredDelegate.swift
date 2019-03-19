/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

/// Sub Interface of `OstBaseInterface` It declares pinEntered api of Workflows.
public protocol OstDeviceRegisteredDelegate: OstBaseDelegate {
    
    /// SDK user will use it to acknowledge device registration.
    ///
    /// - Parameter apiResponse: Kit API response
    func deviceRegistered(_ apiResponse: [String: Any]) throws
}
