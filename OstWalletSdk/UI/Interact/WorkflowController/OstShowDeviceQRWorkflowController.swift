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
    
    @objc
    init(userId: String, passphrasePrefixDelegate: OstPassphrasePrefixDelegate?) {
        super.init(userId: userId,
                   passphrasePrefixDelegate: passphrasePrefixDelegate,
                   workflowType: .showDeviceQR)
    }
    
    override func vcIsMovingFromParent(_ notification: Notification) {
        if nil != notification.object {
            if ((notification.object! as? OstBaseViewController) === self.deviceQRVC) {
                self.postFlowInterrupted(error: OstError("ui_i_wc_sdqrwc_vimfp_1", .userCanceled))
            }
        }
    }
    
    override func performUserDeviceValidation() throws {
        try super.performUserDeviceValidation()
        
        if !self.currentDevice!.isStatusRegistered {
            throw OstError("ui_i_wc_sdqewc_pudv_1", OstErrorCodes.OstErrorCode.deviceNotRegistered)
        }
    }
    
    override func shouldCheckCurrentDeviceAuthorization() -> Bool {
        return false
    }
    
    override func performUIActions() {
        do {
            let qr = try OstWalletSdk.getAddDeviceQRCode(userId: self.userId)
            openShowDeviceQRViewController(qr: qr)
        }catch let err {
            self.postFlowInterrupted(error: err as! OstError)
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
    
    override func cleanUp() {
        deviceQRVC?.removeViewController(flowEnded: true)
        deviceQRVC = nil
        super.cleanUp()
    }
    
    //MARK: - OstJsonApiDelegate
    func onOstJsonApiSuccess(data: [String : Any]?) {
        var device: OstDevice? = nil
        var deviceAddress: String? = nil
        let resultData = OstJsonApi.getResultAsDictionary(apiData: data)
        
        if nil != resultData {
            device = try? OstDevice(resultData!)
            deviceAddress = device?.address
        }
        
        if nil != deviceAddress {
            
            if device!.isStatusAuthorized {
                let storedDevice = try! OstDevice.getById(deviceAddress!)
                postFlowComplete(entity: storedDevice!, type: .device) 
                return
            }else if device!.isStatusAuthorizing {
                let storedDevice = try! OstDevice.getById(deviceAddress!)
                requestAcknowledged(workflowContext: getWorkflowContext(),
                                    ostContextEntity: OstContextEntity(entity: storedDevice!, entityType: .device))
                pollingForAuthorizeDevice()
                return
            }
        }
        
        let workflowConfig = OstContent.getShowQrControllerVCConfig()
        let unauthorizedAlertConfig = workflowConfig["unauthorized_alert"] as! [String: Any]
        
        showApiFailureMessage(title: unauthorizedAlertConfig["title"] as? String ?? "",
                              message: unauthorizedAlertConfig["message"] as? String ?? "")
    }
    
    func onOstJsonApiError(error: OstError?, errorData: [String : Any]?) {
        let workflowConfig = OstContent.getShowQrControllerVCConfig()
        let failureAlertConfig = workflowConfig["api_failure_alert"] as! [String: Any]
        showApiFailureMessage(title: failureAlertConfig["title"] as? String ?? "",
                              message: failureAlertConfig["message"] as? String ?? "")
    }
    
    func showApiFailureMessage(title: String, message: String) {
        hideLoader()
        let alert = OstUIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        alert.show()
    }
    
    @objc
    func dismiss() {
        hideLoader()
    }
    
    /// Polling for device
    func pollingForAuthorizeDevice() {
        let successCallback: ((OstDevice) -> Void) = {[weak self] ostDevice in
            self?.postFlowComplete(entity: ostDevice, type: .device)
        }
        
        let failureCallback:  ((OstError) -> Void) = {[weak self] error in
            self?.postFlowInterrupted(error: error)
        }
        
        OstDevicePollingService(userId: self.userId,
                                deviceAddress: self.currentDevice!.address!,
                                successStatus: OstDevice.Status.AUTHORIZED.rawValue,
                                failureStatus: OstDevice.Status.REGISTERED.rawValue,
                                successCallback: successCallback,
                                failureCallback:failureCallback).perform()
    }
}
