/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import OstWalletSdk

class LogoutAllSessions: BaseWalletWorkflowView {
    
    // Mark - Sub Views
    let logoImageView: UIImageView = {
        let baseImage = UIImage.init(named: "Logo")
        let logoImageView = UIImageView(image: baseImage);
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        return logoImageView
    }()
    
    override func didTapNext(sender: Any) {
        super.didTapNext(sender: sender)
        let currentUser = CurrentUser.getInstance()
        OstWalletSdk.logoutAllSessions(userId: currentUser.ostUserId!,
                                       delegate: self.sdkInteract)
    }
    
    override func addSubViews() {
        let scrollView = self;
        scrollView.addSubview(logoImageView)
        
        super.addSubViews()
         self.nextButton.setTitle("Logout All Sessions", for: .normal);
    }
    
    override func addSubviewConstraints() {
        let scrollView = self;
        
        // Constraints
        var constraints = [NSLayoutConstraint]()
        constraints.append(NSLayoutConstraint(item: logoImageView,
                                              attribute: .top,
                                              relatedBy: .equal,
                                              toItem: scrollView.contentLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1,
                                              constant: 100))
        constraints.append(NSLayoutConstraint(item: logoImageView,
                                              attribute: .centerX,
                                              relatedBy: .equal,
                                              toItem: scrollView,
                                              attribute: .centerX,
                                              multiplier: 1,
                                              constant: 0))
        NSLayoutConstraint.activate(constraints)
        super.addBottomSubviewConstraints(afterView:self.logoImageView);
    }

    override func receivedSdkEvent(eventData: [String : Any]) {
        super.receivedSdkEvent(eventData: eventData)
        let eventType:OstSdkInteract.WorkflowEventType = eventData["eventType"] as! OstSdkInteract.WorkflowEventType;
        let workflowContext:OstWorkflowContext = eventData["workflowContext"] as! OstWorkflowContext;
        let workFlowType = workflowContext.workflowType;
        
        if eventType == OstSdkInteract.WorkflowEventType.flowComplete
            && workFlowType == .logoutAllSessions {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2) , execute: {
                let rootViewController: HomeViewController = self.window!.rootViewController as! HomeViewController
                rootViewController.dismiss(animated: false, completion: nil)
                rootViewController.showLoginViewController(animated: true)
            })
        }
        
    }
}
