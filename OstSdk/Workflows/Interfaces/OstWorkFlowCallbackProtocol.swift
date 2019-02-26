//
//  OstWorkFlowCallbackProtocol.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

/// OstWorkFlowCallback implemented by SDK user to perform prerequisites task.
/// These tasks are assigned by SDK workflows with help of callbacks.
public protocol OstWorkFlowCallbackProtocol {
    
    /// Register device passed as parameter.
    ///
    /// - Parameters:
    ///   - apiParams: Register Device API parameters.
    ///   - ostDeviceRegisteredProtocol: To pass response.
    func registerDevice(_ apiParams: [String: Any], delegate ostDeviceRegisteredProtocol: OstDeviceRegisteredProtocol)
    
    /// Pin needed to check the authenticity of the user.
    /// Developers should show pin dialog on this callback.
    ///
    /// - Parameters:
    ///   - userId: Id of user whose password and pin are needed.
    ///   - ostPinAcceptProtocol: To pass pin
    func getPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol)
    
    /// Inform SDK user about invalid pin.
    /// Developers should show invalid pin error and ask for pin again on this callback.
    ///
    /// - Parameters:
    ///   - userId: Id of user whose password and pin are needed.
    ///   - ostPinAcceptProtocol: To pass another pin.
    func invalidPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol)
    
    /// Inform SDK user that entered pin is validated.
    /// Developers should dismiss pin dialog on this callback.
    /// - Parameter userId: Id of user whose pin and password has been validated.
    func pinValidated(_ userId: String)
    
    /// Inform SDK user the the flow is complete.
    ///
    /// - Parameter workflowContext: A context that describes the workflow for which the callback was triggered.
    /// - Parameter ostContextEntity: Status of the flow.
    func flowComplete1(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity)


    /// Inform SDK user that flow is interrupted with errorCode.
    /// Developers should dismiss pin dialog (if open) on this callback.
    ///
    /// - Parameter workflowContext: A context that describes the workflow for which the callback was triggered.
    /// - Parameter ostError: Reason of interruption.
    func flowInterrupted1(workflowContext: OstWorkflowContext, error: OstError1)
    
    /// Ask SDK user to determine workflow how to add device.
    ///
    /// - Parameter addDeviceFlowInterface: To device type add device flow.
    func determineAddDeviceWorkFlow(_ ostAddDeviceFlowProtocol: OstAddDeviceFlowProtocol)
    
    /// Ask SDK user to show the provided QR code.
    ///
    /// - Parameters:
    ///   - startPollingProtocol: To start polling.
    ///   - qrImage: QR code image.
    func showQR(_ startPollingProtocol: OstStartPollingProtocol , image qrImage: CIImage)

    /// Wallet words needed to recover user wallet.
    ///
    /// - Parameter ostWalletWordsAcceptProtocol: To pass 12 wallet words.
    func getWalletWords(_ ostWalletWordsAcceptProtocol: OstWalletWordsAcceptProtocol)
    
    /// Inform SDK user about invalid pin.
    ///
    /// - Parameter ostWalletWordsAcceptProtocol: To pass 12 wallet words.
    func invalidWalletWords(_ ostWalletWordsAcceptProtocol: OstWalletWordsAcceptProtocol);

    /// Inform SDK user that entered 12 wallet words is validated
    func walletWordsValidated()
    
    /// Show paper wallet
    ///
    /// - Parameter mnemonics: array of Words.
    func showPaperWallet(mnemonics: [String])
    
    
    /// Verify data which is scan from QR-Code
    ///
    /// - Parameters:
    ///   - workflowContext: OstWorkflowContext
    ///   - ostContextEntity: OstContextEntity
    ///   - delegate: callback
    func verifyData(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity, delegate: OstValidateDataProtocol)
    
    /// Acknowledge user about the request which is going to make by SDK.
    ///
    /// - Parameters:
    ///   - workflowContext: OstWorkflowContext
    ///   - ostContextEntity: OstContextEntity
    func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity)
}
