/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

public class OstLoaderIndicator: UIAlertController, OstWorkflowLoader {
    
    @objc
    class func getInstance(workflowType: OstWorkflowType) -> OstWorkflowLoader {
        let loaderIndicator = OstLoaderIndicator(title: "", message: "", preferredStyle: .alert)
        loaderIndicator.workflowType = workflowType
        
        return loaderIndicator
    }
    
    fileprivate var workflowType: OstWorkflowType? = nil
    fileprivate var activityIndicator: UIActivityIndicatorView? = nil
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let activ = UIActivityIndicatorView(style: .gray)
        activ.color = UIColor.color(22, 141, 193)
        activ.startAnimating()
        activ.hidesWhenStopped =  true
        activ.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activ)
        activ.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activ.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
        
        activityIndicator = activ
    }
    
    fileprivate func updateTitle(_ text: String) {
        self.title = "\n\(text)"
    }
    
    deinit {
        Logger.log(message: "OstLoaderIndicator: \(self.title ?? "")", parameterToPrint: nil)
    }
    
    
    //MARK: - Open OstWorkflowLoader
    @objc
    public func onInitLoader(workflowConfig: [String : Any]) {
        let text = OstContent.getInitialLoaderText(for: self.workflowType!)
        updateTitle(text)
    }
    
    @objc
    public func onPostAuthentication(workflowConfig: [String : Any]) {
        let text = OstContent.getLoaderText(for: self.workflowType!)
        updateTitle(text)
    }
    
    @objc
    public func onAcknowledge(workflowConfig: [String : Any]) {
        let text = "Waiting for confirmation..."
        updateTitle(text)
    }
    
    @objc
    open func onSuccess(workflowContext: OstWorkflowContext,
                        contextEntity: OstContextEntity,
                        workflowConfig: [String : Any],
                        loaderComplectionDelegate: OstLoaderCompletionDelegate) {
        
        activityIndicator?.stopAnimating()
        loaderComplectionDelegate.dismissWorkflow()
    }
    
    @objc
    open func onFailure(workflowContext: OstWorkflowContext,
                        error: OstError,
                        workflowConfig: [String : Any],
                        loaderComplectionDelegate: OstLoaderCompletionDelegate) {
        activityIndicator?.stopAnimating()
        loaderComplectionDelegate.dismissWorkflow()
    }
}
