//
//  OstDeviceRegisteredProtocol.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

/// Sub Interface of `OstBaseInterface` It declares pinEntered api of Workflows.
public protocol OstDeviceRegisteredProtocol: OstBaseProtocol {
    
    /// SDK user will use it to acknowledge device registration.
    ///
    /// - Parameter apiResponse: Kit API response
    func deviceRegistered(_ apiResponse: [String: Any])
}
