//
//  OstPinAcceptDelegate.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation


/// Sub Interface of `OstBaseInterface` It declares pinEntered api of Workflows.
public protocol OstPinAcceptDelegate: OstBaseDelegate {
    
    /// SDK user will use it to pass user pin to SDK.
    ///
    /// - Parameters:
    ///   - userPin: User pin passed from Application
    ///   - passphrasePrefix: Application provided passphrase prefix
    func pinEntered(_ userPin: String, passphrasePrefix: String)
}
