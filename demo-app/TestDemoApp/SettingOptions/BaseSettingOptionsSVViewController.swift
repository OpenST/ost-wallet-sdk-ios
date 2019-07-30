//
//  BaseSettingOptionsViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import Foundation
import OstWalletSdk

class BaseSettingOptionsSVViewController: OstBaseScrollViewController, OWFlowCompleteDelegate, OWFlowInterruptedDelegate, OWRequestAcknowledgedDelegate {
    
    //MAKR: - Components
    let leadLabel: UILabel = {
        var label = OstUIKit.leadLabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    var progressIndicator: OstProgressIndicator? = nil
    
    //MARK: - Variables
    
    var workflowDelegate: OstWorkflowCallbacks {
        let delegate = OstSdkInteract.getInstance.getWorkflowCallback(forUserId: CurrentUserModel.getInstance.ostUserId!)
        OstSdkInteract.getInstance.subscribe(forWorkflowId: delegate.workflowId, listner: self)
        return delegate
    }
    func getLeadLabelText() -> String {
        return ""
    }
    
    //MAKR: - Add Views
    deinit {
        print("deinit \(String(describing: self))")
    }
    
    override func addSubviews() {
        super.addSubviews()
        addSubview(leadLabel)
        leadLabel.text = getLeadLabelText()
    }
   
    //MARK: - Add Constraints
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addLeadLabelLayoutConstraints()
    }
    
    func addLeadLabelLayoutConstraints() {
        leadLabel.topAlignWithParent(multiplier: 1, constant: 20)
        leadLabel.applyBlockElementConstraints()
    }
    
    //MARK: - Sdk Interact Delegate
    
    func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        progressIndicator?.showAcknowledgementAlert(forWorkflowType: workflowContext.workflowType)
    }
    
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        if error.messageTextCode == .userCanceled {
            progressIndicator?.hide()
            return
        }
        showFailureAlert(workflowId: workflowId,
                         workflowContext: workflowContext,
                         error: error)
    }
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        showSuccessAlert(workflowId: workflowId,
                         workflowContext: workflowContext,
                         contextEntity: contextEntity)
    }
    
    //MARK: - Alert
    
    func showSuccessAlert(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
        progressIndicator?.showSuccessAlert(forWorkflowType: workflowContext.workflowType,
                                            onCompletion: {[weak self] (_) in
                                                
                                                self?.onFlowComplete(workflowId: workflowId,
                                                                     workflowContext: workflowContext,
                                                                     contextEntity: contextEntity)
        })
    }
    
    func showFailureAlert(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        progressIndicator?.showFailureAlert(forWorkflowType: workflowContext.workflowType,
                                            onCompletion: {[weak self] (_) in
                                                
                                                self?.onFlowInterrupted(workflowId: workflowId,
                                                                        workflowContext: workflowContext,
                                                                        error: error)
        })
    }
    
    //MARK: - OnCompletion
    func onFlowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
    }
    
    func onFlowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        
    }
    
    
}
