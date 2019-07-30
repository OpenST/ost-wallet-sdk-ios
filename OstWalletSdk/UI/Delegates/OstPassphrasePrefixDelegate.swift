//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation;
import OstWalletSdk


@objc public protocol OstPassphrasePrefixAcceptDelegate: OstBaseDelegate {
    
    @objc
    func setPassphrase(ostUserId:String, passphrase:String);
}

@objc public protocol OstPassphrasePrefixDelegate {
    @objc
    func getPassphrase(ostUserId:String,
                       workflowContext: OstWorkflowContext,
                       delegate: OstPassphrasePrefixAcceptDelegate);
}
