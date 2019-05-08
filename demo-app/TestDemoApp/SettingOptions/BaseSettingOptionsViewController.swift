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

class BaseSettingOptionsViewController: OstBaseScrollViewController, OstFlowCompleteDelegate, OstFlowInterruptedDelegate, OstRequestAcknowledgedDelegate {
    
    //MAKR: - Components
    let leadLabel: UILabel = {
        var label = OstUIKit.leadLabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    var progressIndicator: OstProgressIndicator? = OstProgressIndicator(progressText: "")
    
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
        addSubview(progressIndicator!)
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
    
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        let message = """
            \(getNavBarTitle()) flow interrupted.
            \(error.errorMessage)
        """
        progressIndicator?.progressText = message
    }
    
    func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        progressIndicator?.progressText = "\(getNavBarTitle()) request acknowledged."
    }
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
         progressIndicator?.progressText = "\(getNavBarTitle()) flow complete."
    }
}
