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

class BaseSettingOptionsViewController: OstBaseScrollViewController, FlowCompleteDelegate, FlowInterruptedDelegate, RequestAcknowledgedDelegate {
    
    //MAKR: - Components
    let leadLabel: UILabel = {
        var label = OstUIKit.leadLabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    //MARK: - Variables
    
    var workflowDelegate: OstWorkflowDelegate {
        let delegate = SdkInteract.getInstance.getWorkflowCallback()
        SdkInteract.getInstance.subscribe(forWorkflowId: delegate.workflowId, listner: self)
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
        leadLabel.topAlignWithParent()
        leadLabel.applyBlockElementConstraints()
    }
    
    //MARK: - Sdk Interact Delegate
    
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        
    }
    
    func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
    }
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
    }
}
