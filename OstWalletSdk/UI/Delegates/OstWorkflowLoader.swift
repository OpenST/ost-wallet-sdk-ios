/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc public protocol OstWorkflowLoader where Self: UIViewController {
    
    /// Initialization loader callback to update loader
    /// - Parameter workflowConfig: Workflow related config, which is set in setContentConfig() method
    @objc
    func onInitLoader(workflowConfig: [String: Any])
    
    /// Pin provided callback to update loader
    /// - Parameter workflowConfig: Workflow related config, which is set in setContentConfig() method
    @objc
    func onPostAuthentication(workflowConfig: [String: Any])
    
    /// Workflow acknowledge callback to update loader
    /// - Parameter workflowConfig: Workflow related config, which is set in setContentConfig() method
    @objc
    func onAcknowledge(workflowConfig: [String: Any])
    
    /// Workflow success callback to show success message on loader
    /// - Parameters:
    ///   - workflowContext: A context that describes the workflow for which the callback was triggered.
    ///   - contextEntity: Context Entity
    ///   - workflowConfig: Workflow related config, which is set in setContentConfig() method.
    ///   - loaderCompletionDelegate: Loader complection delegate
    @objc
    func onSuccess(workflowContext: OstWorkflowContext,
                   contextEntity: OstContextEntity,
                   workflowConfig: [String: Any],
                   loaderCompletionDelegate: OstLoaderCompletionDelegate)
    
    /// Workflow failure callback to show error message on loader
    /// - Parameters:
    ///   - workflowContext: A context that describes the workflow for which the callback was triggered.
    ///   - error: Error Entity
    ///   - workflowConfig: Workflow related config, which is set in setContentConfig() method.
    ///   - loaderComplectionDelegate: Loader complection delegate
    @objc
    func onFailure(workflowContext: OstWorkflowContext,
                   error: OstError,
                   workflowConfig: [String: Any],
                   loaderCompletionDelegate: OstLoaderCompletionDelegate)
}
