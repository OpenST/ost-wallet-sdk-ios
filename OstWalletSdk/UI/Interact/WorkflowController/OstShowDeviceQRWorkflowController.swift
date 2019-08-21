/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstShowDeviceQRWorkflowController: OstBaseWorkflowController, OstJsonApiDelegate {

    var deviceQRVC: OstDeviceQRViewController? = nil
    
    override func performUIActions() {
        do {
            let qr = try OstWalletSdk.getAddDeviceQRCode(userId: self.userId)
            openShowDeviceQRViewController(qr: qr)
        }catch let err {
            self.postFlowInterrupted(error: err as! OstError)
        }
    }
    
    override func vcIsMovingFromParent(_ notification: Notification) {
        if nil != notification.object {
            if ((notification.object! as? OstBaseViewController) === self.deviceQRVC) {
                self.postFlowInterrupted(error: OstError("ui_i_wc_sdqrwc_vimfp_1", .userCanceled))
            }
        }
    }
    
    func openShowDeviceQRViewController(qr: CIImage) {
        DispatchQueue.main.async {
            self.deviceQRVC = OstDeviceQRViewController
                .newInstance(qrCode: qr,
                             for: self.userId,
                             checkStatusCallback: {[weak self] in
                          self?.checkDeviceStatus()
                })
            
            self.deviceQRVC!.presentVCWithNavigation()
        }
    }
    
    func checkDeviceStatus() {
        hideLoader()
        showLoader(for: .showDeviceQR)
        OstJsonApi.getCurrentDevice(forUserId: self.userId, delegate: self)
    }
    
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .showDeviceQR)
    }
    
    override func cleanUp() {
        deviceQRVC?.removeViewController(flowEnded: true)
        deviceQRVC = nil
        super.cleanUp()
    }
    
    //MARK: - OstJsonApiDelegate
    func onOstJsonApiSuccess(data: [String : Any]?) {
        var device: OstDevice? = nil
        var deviceAddress: String? = nil
        if nil != data {
            device = try? OstDevice(data!)
            deviceAddress = device?.address
        }
     
        if nil != deviceAddress &&  (device!.isStatusAuthorizing || device!.isStatusAuthorized) {
            let storedDevice = try! OstDevice.getById(deviceAddress!)
            flowComplete(workflowContext: getWorkflowContext(),
                         ostContextEntity: OstContextEntity(entity: storedDevice!, entityType: .device))
            return
        }
        
        let workflowConfig = getControllerConfig()
        let unauthorizedAlertConfig = workflowConfig["unauthorized_alert"] as! [String: Any]

        showApiFailureMessage(title: unauthorizedAlertConfig["title"] as? String ?? "",
                              message: unauthorizedAlertConfig["message"] as? String ?? "")
    }
    
    func onOstJsonApiError(error: OstError?, errorData: [String : Any]?) {
        let workflowConfig = getControllerConfig()
        let failureAlertConfig = workflowConfig["api_failure_alert"] as! [String: Any]
        showApiFailureMessage(title: failureAlertConfig["title"] as? String ?? "",
                              message: failureAlertConfig["message"] as? String ?? "")
    }
    
    func showApiFailureMessage(title: String, message: String) {
        progressIndicator?.showAlert(withTitle: title,
                                     message: message,
                                     duration: 0,
                                     actionButtonTitle: "Ok",
                                     actionButtonTapped: nil,
                                     cancelButtonTitle: nil, cancelButtonTapped: nil,
                                     onHideAnimationCompletion: nil)
    }
    
    func getControllerConfig() -> [String: Any] {
        let workflowConfig = OstContent.getInstance()
            .getControllerConfig(for: "show_qr",
                                 inWorkflow: OstContent.getWorkflowName(for: .showDeviceQR))
        return workflowConfig
    }
}
