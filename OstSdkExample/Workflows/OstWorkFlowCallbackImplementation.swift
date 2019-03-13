//
//  OstWorkFlowCallbackImplementation.swift
//  Example
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk

class OstWorkFlowCallbackImplementation: OstWorkFlowCallbackDelegate {
   
    var mappyUserId: String
    init(mappyUserId: String) {
        self.mappyUserId = mappyUserId
    }
    
    func registerDevice(_ apiParams: [String : Any], delegate ostDeviceRegisteredProtocol: OstDeviceRegisteredDelegate) {
        
        MappyRegisterDevice().registerDevice(apiParams as [String : AnyObject], forUserId: mappyUserId,  onSuccess: { (deviceObj) in
            do {
                try ostDeviceRegisteredProtocol.deviceRegistered(["device":apiParams])
            }catch let error{
                Logger.log(message: "registerDevice", parameterToPrint: error)
            }
        }) { (failureObj) in
            Logger.log(message: "registerDevice failed", parameterToPrint: failureObj)
        }
        
       
    }
    
    func getPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptDelegate) {
        ostPinAcceptProtocol.pinEntered("123456", applicationPassword: "fjkaefbhawebkfkuhwabfuwaebfyu3bfyubruq23h87hriuq3hrniuq")
    }
    
    func invalidPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptDelegate) {
        
    }
    
    func pinValidated(_ userId: String) {
        
    }
    
    func biomatricAuth() {
        let callbackObj = OstWorkFlowCallbackImplementation(mappyUserId: "5c6ec4eabd55c229fd62877f")
        OstSdk.perfrom(userId: "20daf895-436e-496f-ad18-5031f2fff8e7", payload: "", delegate: callbackObj)
    }
    
    func flowComplete(_ ostContextEntity: OstContextEntity) {
        
    }
    func flowComplete1(workflowContext: OstWorkflowContext, ostContextEntity: OstContextEntity) {
        switch workflowContext.workflowType {
        case .setupDevice:
            Logger.log(message: "setupDevice flowComplete", parameterToPrint: (ostContextEntity.entity as! OstBaseEntity).data)
            
            let currentDevice: OstCurrentDevice  = ostContextEntity.entity as! OstCurrentDevice
            let user: OstUser = try! OstUser.getById(currentDevice.userId!)!
            
            if (user.isActivated() && currentDevice.status!.uppercased() == "REGISTERED") {
                AddDevice(mappyUserId: mappyUserId, userId: user.id).perform()
            }else if (!user.isActivated()){
                _ = try! ActivateUser(userId: user.id, tokenId: user.tokenId!, mappyUserId: mappyUserId, pin: "123456", password: "fjkaefbhawebkfkuhwabfuwaebfyu3bfyubruq23h87hriuq3hrniuq").perform()
            }else {
                OstSdk.addSession(userId: user.id, spendingLimit: "10000000", expiresAfter: Double(3600), delegate: self)
            }
            
        case .activateUser:
            Logger.log(message: "activateUser flowComplete", parameterToPrint: (ostContextEntity.entity as! OstBaseEntity).data)
            
            let user: OstUser  = ostContextEntity.entity as! OstUser
            OstSdk.addSession(userId: user.id, spendingLimit: "10000000", expiresAfter: Double(3600 * 24), delegate: self)
            
        case .addSession:
            Logger.log(message: "addSession flowComplete", parameterToPrint: (ostContextEntity.entity as! OstBaseEntity).data)
        default:
            return
        }
    }
    
    func flowInterrupted1(workflowContext: OstWorkflowContext, error: OstError1) {
        Logger.log(message: "flowInterrupted for ", parameterToPrint: workflowContext.workflowType)
        Logger.log(message: "error ", parameterToPrint: error)
    }
 
    func showPaperWallet(mnemonics: [String]) {        
    }
}
