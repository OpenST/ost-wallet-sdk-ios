/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc public class OstWorkflowCallbacks: NSObject, OstWorkflowDelegate, OstPassphrasePrefixAcceptDelegate, OstPinInputDelegate {
    /// Mark - Pin extension variables
    var userPin:String? = nil;
    var sdkPinAcceptDelegate:OstPinAcceptDelegate? = nil;
    var passphrasePrefixDelegate: OstPassphrasePrefixDelegate?
    var getPinViewController: OstPinViewController? = nil

    /// Mark - Workflow callback vars.
    public let workflowId: String
    let userId: String
  
    var loaderPresenter: OstPresenterHelper? = nil
    var progressIndicator: OstProgressIndicator? = nil
    
    private var interact: OstSdkInteract {
        return OstSdkInteract.getInstance
    }

    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: Ost use id
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    init(userId: String,
         passphrasePrefixDelegate:OstPassphrasePrefixDelegate?) {
        
        self.userId = userId;
        self.workflowId = UUID().uuidString;
        self.passphrasePrefixDelegate = passphrasePrefixDelegate;
    }
    
    deinit {
        print("OstWorkflowCallbacks :: I am deinit for \(self.workflowId)")
    }
    
    func observeViewControllerIsMovingFromParent() {
        //self.setPinViewController
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(vcIsMovingFromParent(_:)),
                                               name: .ostVCIsMovingFromParent,
                                               object: nil)
    }

    @objc func vcIsMovingFromParent(_ notification: Notification) {
        if ( nil != notification.object && notification.object! as? OstBaseViewController === self.getPinViewController ) {
            self.getPinViewControllerDismissed();
        }
    }
        
    @objc public func registerDevice(_ apiParams: [String : Any], delegate: OstDeviceRegisteredDelegate) {
        // To-Do: Ensure its setupDevice workflow.
        // else do not do it. Logout the user.
    }

    @objc public func verifyData(workflowContext: OstWorkflowContext,
                                 ostContextEntity: OstContextEntity,
                                 delegate: OstValidateDataDelegate) {
        
    }
    
    @objc public func flowComplete(workflowContext: OstWorkflowContext,
                      ostContextEntity: OstContextEntity) {
        
        var eventData = OstInteractEventData()
        eventData.contextEntity = ostContextEntity
        
        let uiWorkflowId = self.workflowId;
        eventData.workflowContext = OstUIWorkflowContext(context: workflowContext, uiWorkflowId:  uiWorkflowId);
        
        self.interact.broadcaseEvent(eventType: .flowComplete, eventHandler: eventData);
    }
    
    @objc public func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
    
        var eventData = OstInteractEventData()
        eventData.error = error
        
        let uiWorkflowId = self.workflowId;
        eventData.workflowContext = OstUIWorkflowContext(context: workflowContext, uiWorkflowId:  uiWorkflowId);
        
        self.interact.broadcaseEvent(eventType: .flowInterrupted, eventHandler: eventData);
    }
    
    @objc public func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        
        var eventData = OstInteractEventData()
        eventData.contextEntity = ostContextEntity
        
        let uiWorkflowId = self.workflowId;
        eventData.workflowContext = OstUIWorkflowContext(context: workflowContext, uiWorkflowId:  uiWorkflowId);

        interact.broadcaseEvent(eventType: .requestAcknowledged, eventHandler: eventData)
    }
    
    @objc public func pinValidated(_ userId: String) {
        
    }
    
    public func cancelFlow() {
        self.cancelPinAcceptor();
    }
    
    func cleanUp() {
        self.cleanUpPinViewController();
        hideLoader()
    }
    
  func getLoader(for workflowType: OstWorkflowType) -> OstWorkflowLoader {
     let loaderManager = OstResourceProvider.getLoaderManger()
     let loader: OstWorkflowLoader = loaderManager.getLoader(workflowType: workflowType)
     return loader
   }
   
    func showLoader(for workflowType: OstWorkflowType) {
//        let progressText = OstContent.getLoaderText(for: workflowType)
//        showLoader(progressText: progressText)
      let loader: OstWorkflowLoader
      if nil == loaderPresenter {
        loader = getLoader(for: workflowType)
        presentLoader(loader)
      }else {
        loader = loaderPresenter!.vc!
      }
      
      loader.onPostAuthentication()
    }
    
    func showInitialLoader(for workflowType: OstWorkflowType) {
//        let progressText = OstContent.getInitialLoaderText(for: workflowType)
//        showLoader(progressText: progressText)
      let loader: OstWorkflowLoader
      if nil == loaderPresenter {
        loader = getLoader(for: workflowType)
        presentLoader(loader)
      }else {
        loader = loaderPresenter!.vc!
      }
      
      loader.onInitLoader()
    }
  
  func presentLoader(_ loader: OstWorkflowLoader) {
    let presenter = OstPresenterHelper()
    presenter.present(loader: loader)
    self.loaderPresenter = presenter
  }
    
    func showLoader(progressText: String) {
        DispatchQueue.main.async {
            if ( nil != self.progressIndicator ) {
                if ( nil != self.progressIndicator!.alert ) {
                    //progressIndicator is showing.
                    self.progressIndicator?.progressText = progressText
                    return;
                }
            }
            self.progressIndicator = OstProgressIndicator(progressText: progressText)
            self.progressIndicator?.show()
        }
    }
    
    func showLoader(progressTextCode: OstProgressIndicatorTextCode) {
        DispatchQueue.main.async {
            if ( nil != self.progressIndicator ) {
                if ( nil != self.progressIndicator!.alert ) {
                    //progressIndicator is showing.
                    self.progressIndicator?.textCode = progressTextCode
                    return;
                }
            }
            self.progressIndicator = OstProgressIndicator(textCode: progressTextCode)
            self.progressIndicator?.show()
        }
    }
    
    func hideLoader() {
        progressIndicator?.hide()
        progressIndicator = nil
        loaderPresenter?.dismiss(animated: true)
        loaderPresenter = nil
    }
}
