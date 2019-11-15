/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc public protocol OstWorkflowLoader where Self: UIViewController {
    
    @objc
    func onInitLoader(workflowConfig: [String: Any])
    
    @objc
    func onPostAuthentication(workflowConfig: [String: Any])
    
    @objc
    func onAcknowledge(workflowConfig: [String: Any])
    
    @objc
    func onSuccess(workflowContext: OstWorkflowContext,
                   contextEntity: OstContextEntity,
                   workflowConfig: [String: Any],
                   loaderComplectionDelegate: OstLoaderCompletionDelegate)
    
    @objc
    func onFailure(workflowContext: OstWorkflowContext,
                   error: OstError,
                   workflowConfig: [String: Any],
                   loaderComplectionDelegate: OstLoaderCompletionDelegate)
    
    @objc
    func onAlert(title: String,
                 message: String?,
                 buttonText: String,
                 alertDelegate: OstAlertCompletionDelegate)
}
