/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */


import Foundation

/// OstWorkFlowCallback implemented by SDK user to perform prerequisites task.
/// These tasks are assigned by SDK workflows with help of callbacks.
public protocol OstWorkflowDelegate {
    
    /// Register device passed as parameter.
    ///
    /// - Parameters:
    ///   - apiParams: Register Device API parameters.
    ///   - delegate: To pass response.
    func registerDevice(_ apiParams: [String: Any],
                        delegate: OstDeviceRegisteredDelegate)
    
    /// Pin needed to check the authenticity of the user.
    /// Developers should show pin dialog on this callback.
    ///
    /// - Parameters:
    ///   - userId: Id of user whose passphrase prefix and pin are needed.
    ///   - delegate: To pass pin
    func getPin(_ userId: String,
                delegate: OstPinAcceptDelegate)
    
    /// Inform SDK user about invalid pin.
    /// Developers should show invalid pin error and ask for pin again on this callback.
    ///
    /// - Parameters:
    ///   - userId: User id whose passphrase prefix and pin failed to validate
    ///   - delegate: To pass another pin.
    func invalidPin(_ userId: String,
                    delegate: OstPinAcceptDelegate)
    
    /// Inform SDK user that entered pin is validated.
    /// Developers should dismiss pin dialog on this callback.
    /// - Parameter userId: Id of user whose pin and passphrase prefix has been validated.
    func pinValidated(_ userId: String)
    
    /// Inform SDK user the the flow is complete.
    ///
    /// - Parameter workflowContext: A context that describes the workflow for which the callback was triggered.
    /// - Parameter ostContextEntity: Status of the flow.
    func flowComplete(workflowContext: OstWorkflowContext,
                      ostContextEntity: OstContextEntity)

    /// Inform SDK user that flow is interrupted with errorCode.
    /// Developers should dismiss pin dialog (if open) on this callback.
    ///
    /// - Parameter workflowContext: A context that describes the workflow for which the callback was triggered.
    /// - Parameter ostError: Reason of interruption.
    func flowInterrupted(workflowContext: OstWorkflowContext,
                         error: OstError)
    
    /// Verify data which is scan from QR-Code
    ///
    /// - Parameters:
    ///   - workflowContext: OstWorkflowContext
    ///   - ostContextEntity: OstContextEntity
    ///   - delegate: callback
    func verifyData(workflowContext: OstWorkflowContext,
                    ostContextEntity: OstContextEntity,
                    delegate: OstValidateDataDelegate)
    
    /// Acknowledge user about the request which is going to make by SDK.
    ///
    /// - Parameters:
    ///   - workflowContext: OstWorkflowContext
    ///   - ostContextEntity: OstContextEntity
    func requestAcknowledged(workflowContext: OstWorkflowContext,
                             ostContextEntity: OstContextEntity)
}
