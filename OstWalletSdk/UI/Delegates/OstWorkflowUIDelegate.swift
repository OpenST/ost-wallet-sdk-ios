/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

@objc public protocol OstWorkflowUIDelegate: AnyObject {
    
    /// Acknowledge user about the request which is going to make by SDK.
    ///
    /// - Parameters:
    ///   - workflowId: Workflow id
    ///   - workflowContext: A context that describes the workflow for which the callback was triggered.
    ///   - contextEntity: Context Entity
    @objc
    func requestAcknowledged(workflowId: String,
                             workflowContext: OstWorkflowContext,
                             contextEntity: OstContextEntity)
    
    
    /// Inform SDK user the the flow is complete.
    ///
    /// - Parameters:
    ///   - workflowId: Workflow id
    ///   - workflowContext: A context that describes the workflow for which the callback was triggered.
    ///   - contextEntity: Context Entity
    @objc
    func flowComplete(workflowId: String,
                      workflowContext: OstWorkflowContext,
                      contextEntity: OstContextEntity)
    
    
    /// Inform SDK user that flow is interrupted with errorCode.
    /// Developers should dismiss pin dialog (if open) on this callback.
    ///
    /// - Parameters:
    ///   - workflowId: Workflow id
    ///   - workflowContext: A context that describes the workflow for which the callback was triggered.
    ///   - error: Context Entity
    @objc
    func flowInterrupted(workflowId: String,
                         workflowContext: OstWorkflowContext,
                         error: OstError)
    
}
