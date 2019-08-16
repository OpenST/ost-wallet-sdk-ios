//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation;


@objc public protocol OstPassphrasePrefixAcceptDelegate: OstBaseDelegate {
    
    /// Set passphrase for user id
    ///
    /// - Parameters:
    ///   - ostUserId: Ost user id
    ///   - passphrase: Passphrase prefix
    @objc
    func setPassphrase(ostUserId:String, passphrase:String)
}

@objc public protocol OstPassphrasePrefixDelegate {
    
    /// Get passphrase prefix from application
    ///
    /// - Parameters:
    ///   - ostUserId: Ost user id
    ///   - workflowContext: Workflow context
    ///   - delegate: Passphrase prefix accept delegate
    @objc
    func getPassphrase(ostUserId:String,
                       workflowContext: OstWorkflowContext,
                       delegate: OstPassphrasePrefixAcceptDelegate)
}
