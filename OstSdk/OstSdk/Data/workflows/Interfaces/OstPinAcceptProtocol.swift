//
//  OstPinAcceptProtocol.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation


/// Sub Interface of `OstBaseInterface` It declares pinEntered api of Workflows.
public protocol OstPinAcceptProtocol: OstBaseProtocol {
    
    /// SDK user will use it to pass user pin to SDK.
    ///
    /// - Parameters:
    ///   - uPin: user pin passed from Application
    ///   - appUserPassword: Application Provided Password for the user
    func pinEntered(_ uPin: String, applicationPassword appUserPassword: String)
}
