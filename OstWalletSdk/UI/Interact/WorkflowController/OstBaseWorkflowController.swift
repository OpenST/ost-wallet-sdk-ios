//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation


@objc class OstBaseWorkflowController: OstWorkflowCallbacks {
    
    var currentUser: OstUser? = nil
    var currentDevice: OstDevice? = nil
    
    private var pinAcceptDelegate: OstPinAcceptDelegate? = nil
    
    var workflowType: OstWorkflowType
    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: Ost use id
    ///   - passphrasePrefixDelegate: Callback to get passphrase prefix from application
    init(userId: String,
         passphrasePrefixDelegate: OstPassphrasePrefixDelegate?,
         workflowType: OstWorkflowType) {
        
        self.workflowType = workflowType
        super.init(userId: userId,
                   passphrasePrefixDelegate: passphrasePrefixDelegate)
        
        OstSdkInteract.getInstance.retainWorkflowCallback(callback: self)
    }
    
    deinit {
        Logger.log(message: "deinit for :: \(String(describing: self)))", parameterToPrint: nil)
    }
    
    func perform() {
        do {
            //Set user and device
            try setVariables()
            
            self.observeViewControllerIsMovingFromParent()
            try performUserDeviceValidation()
            performUIActions()
        }catch let err {
            postFlowInterrupted(error: err as! OstError)
        }
    }

    func setVariables() throws {
        guard let user = OstWalletSdk.getUser(self.userId) else {
            throw OstError("ui_i_wc_bwc_sv_1", .deviceNotSet)
        }
        self.currentUser = user
        
        guard let userDevice = self.currentUser!.getCurrentDevice() else {
            throw OstError("ui_i_wc_bwc_sv_2", .deviceNotSet)
        }
        self.currentDevice = userDevice
    }
    
    func performUserDeviceValidation() throws {
        if !self.currentUser!.isStatusActivated {
            throw OstError("ui_i_wc_bwc_pudv_1", .userNotActivated)
        }
        if shouldCheckCurrentDeviceAuthorization() {
            if !self.currentDevice!.isStatusAuthorized {
                throw OstError("ui_i_wc_bwc_pudv_2", OstErrorCodes.OstErrorCode.deviceNotAuthorized)
            }
        }
    }
    
    /// Should check for current device authorization
    /// This method returns true. Incase workflow don't want to verify deivce authorization
    /// override this method and return false
    /// - Returns: Bool
    func shouldCheckCurrentDeviceAuthorization() -> Bool {
        return true
    }
    
    func performUIActions() {
        fatalError("performUIActions did not override in \(String(describing: self))")
    }
    
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: getWorkflowType())
    }
  
  override func getWorkflowType() -> OstWorkflowType {
    return workflowType
  }
    
    override func getPinVCConfig() -> OstPinVCConfig {
        fatalError("getPinVCConfig did not override in \(String(describing: self))")
    }
    
    override func getPin(_ userId: String, delegate: OstPinAcceptDelegate) {
        hideLoader()
        super.getPin(userId, delegate: delegate)
    }
    
    func postFlowInterrupted(error: OstError) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .microseconds(500)) {
            self.flowInterrupted(workflowContext: self.getWorkflowContext(),
                                 error: error)
        }
    }
    
    func postFlowComplete(entity: Any, type: OstEntityType) {
        DispatchQueue.main.async {
            self.flowComplete(workflowContext: self.getWorkflowContext(),
                              ostContextEntity: OstContextEntity(entity: entity, entityType: type))
        }
    }
    
    override func cleanUp() {
        self.passphrasePrefixDelegate = nil;
        NotificationCenter.default.removeObserver(self);
        super.cleanUp()
    }
    
    /// Mark - OstPassphrasePrefixAcceptDelegate
    override func setPassphrase(ostUserId: String, passphrase: String) {
        if ( self.userId.compare(ostUserId) != .orderedSame ) {
            postFlowInterrupted(error: OstError("ui_i_wc_bwc_sp_1", .pinValidationFailed))
            return
        }
        
        onPassphrasePrefixSet(passphrase: passphrase)
        super.setPassphrase(ostUserId: ostUserId, passphrase: passphrase)
    }
    
    @objc func onPassphrasePrefixSet(passphrase: String) {
        if nil == self.sdkPinAcceptDelegate {
            fatalError("onPassphrasePrefixSet did not override in \(String(describing: self))")
        }
        
        self.sdkPinAcceptDelegate?.pinEntered(self.userPin!,
                                           passphrasePrefix: passphrase)
    }
    
    //MARK: - OstWorkflowUIDelegaete
    override func requestAcknowledged(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowContext: workflowContext, ostContextEntity: ostContextEntity)
        
        if shouldWaitForFinalization() {
           showOnAcknowledgeLoader()
        }else {
            cleanUpWorkflowController()
        }
    }
    
    override func flowComplete(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        super.flowComplete(workflowContext: workflowContext, ostContextEntity: ostContextEntity)
        if nil == loaderPresenter {
            cleanUpWorkflowController()
        }else {
            showOnSuccess(workflowContext: workflowContext,
                          contextEntity: ostContextEntity)
        }
    }
    
    override func flowInterrupted(workflowContext: OstWorkflowContext, error: OstError) {
        super.flowInterrupted(workflowContext: workflowContext, error: error)
        if nil == loaderPresenter {
            cleanUpWorkflowController()
        }else {
            showOnFailure(workflowContext: workflowContext,
                          error: error)
        }
    }
}
