/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class BaseSettingOptionsViewController: OstBaseViewController, OWFlowCompleteDelegate, OWFlowInterruptedDelegate, OWRequestAcknowledgedDelegate {
    
    //MAKR: - Components
    let leadLabel: UILabel = {
        var label = OstUIKit.leadLabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    var progressIndicator: OstProgressIndicator? = nil
    
    //MARK: - Variables
    
    var workflowDelegate: OstWorkflowDelegate {
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
    @objc  func requestAcknowledged(workflowId: String,
                             workflowContext: OstWorkflowContext,
                             contextEntity: OstContextEntity) {
        
        progressIndicator?.showAcknowledgementAlert(forWorkflowType: workflowContext.workflowType)
    }
    
    @objc  func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        if error.messageTextCode != .userCanceled {
            progressIndicator?.showFailureAlert(forWorkflowType: workflowContext.workflowType,
                                                onCompletion: {[weak self] (_) in
                                                    
                                                    self?.onFlowInterrupted(workflowId: workflowId,
                                                                            workflowContext: workflowContext,
                                                                            error: error)
            })
        } else {
            progressIndicator?.hide()
            self.onFlowInterrupted(workflowId: workflowId,
                                   workflowContext: workflowContext,
                                   error: error)
        }
    }

    @objc func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        showSuccessAlert(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
    }
    
    func showSuccessAlert(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        progressIndicator?.showSuccessAlert(forWorkflowType: workflowContext.workflowType,
                                            onCompletion: {[weak self] (_) in
                                                
                                                self?.onFlowComplete(workflowId: workflowId,
                                                                     workflowContext: workflowContext,
                                                                     contextEntity: contextEntity)
        })
    }
    
    //MARK: - OnCompletion
    func onFlowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
    }
    
    func onFlowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        
    }
}
