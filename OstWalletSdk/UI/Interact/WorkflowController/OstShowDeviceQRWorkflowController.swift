/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstShowDeviceQRWorkflowController: OstBaseWorkflowController {
    
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
                self.flowComplete(workflowContext: getWorkflowContext(),
                                  ostContextEntity: OstContextEntity(entity: true, entityType: .boolean))
            }
        }
    }
    
    func openShowDeviceQRViewController(qr: CIImage) {
        DispatchQueue.main.async {
            self.deviceQRVC = OstDeviceQRViewController.newInstance(qrCode: qr, for: self.userId)
            self.deviceQRVC!.presentVCWithNavigation()
        }
    }
    
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowId: self.workflowId, workflowType: .showDeviceQR)
    }
    
    override func cleanUp() {
        deviceQRVC?.removeViewController(flowEnded: true)
        deviceQRVC = nil
        super.cleanUp()
    }
}
