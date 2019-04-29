//
//  SdkInteractDelegate.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 26/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstWalletSdk

protocol SdkInteractDelegate: AnyObject {
}

protocol FlowCompleteDelegate: SdkInteractDelegate{
    func flowComplete(workflowId: String,
                      workflowContext: OstWorkflowContext,
                      contextEntity: OstContextEntity)
}

protocol FlowInterruptedDelegate: SdkInteractDelegate{
    func flowInterrupted(workflowId: String,
                         workflowContext: OstWorkflowContext,
                         error: OstError)
}

protocol RequestAcknowledgedDelegate: SdkInteractDelegate{
    func requestAcknowledged(workflowId: String,
                             workflowContext: OstWorkflowContext,
                             contextEntity: OstContextEntity)
}

