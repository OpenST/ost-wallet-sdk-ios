//
//  OstStartPollingProtocol.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

/// Sub Interface of `OstBaseInterface` It declares startPolling api of Workflows.
public protocol OstStartPollingProtocol: OstBaseProtocol {
   
    /// SDK user will make SDK to start polling for status from kit.
    func startPolling()
}
