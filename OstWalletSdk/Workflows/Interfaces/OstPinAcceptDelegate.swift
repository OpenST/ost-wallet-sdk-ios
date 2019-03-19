/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */


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
