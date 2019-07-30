//
//  SdkInteractDelegate.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 26/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstWalletSdk

protocol OstSdkInteractDelegate: AnyObject {
}

protocol OWFlowCompleteDelegate: OstSdkInteractDelegate{
    func flowComplete(workflowId: String,
                      workflowContext: OstWorkflowContext,
                      contextEntity: OstContextEntity)
}

protocol OWFlowInterruptedDelegate: OstSdkInteractDelegate{
    func flowInterrupted(workflowId: String,
                         workflowContext: OstWorkflowContext,
                         error: OstError)
}

protocol OWRequestAcknowledgedDelegate: OstSdkInteractDelegate{
    func requestAcknowledged(workflowId: String,
                             workflowContext: OstWorkflowContext,
                             contextEntity: OstContextEntity)
}

