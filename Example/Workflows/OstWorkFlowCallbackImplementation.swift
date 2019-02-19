//
//  OstWorkFlowCallbackImplementation.swift
//  Example
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import OstSdk

class OstWorkFlowCallbackImplementation: OstWorkFlowCallbackProtocol {
    var mappyUserId: String
    init(mappyUserId: String) {
        self.mappyUserId = mappyUserId
    }
    
    func registerDevice(_ apiParams: [String : Any], delegate ostDeviceRegisteredProtocol: OstDeviceRegisteredProtocol) {
        
        MappyRegisterDevice().registerDevice(apiParams as [String : AnyObject], forUserId: mappyUserId,  onSuccess: { (deviceObj) in
            do {
                try ostDeviceRegisteredProtocol.deviceRegistered(["device":apiParams])
            }catch let error{
                Logger.log(message: "registerDevice", parameterToPrint: error)
            }
        }) { (failuarObj) in
            Logger.log(message: "registerDevice failed", parameterToPrint: failuarObj)
        }
        
       
    }
    
    func getPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol) {
        
    }
    
    func invalidPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol) {
        
    }
    
    func pinValidated(_ userId: String) {
        
    }
    
    func flowComplete(_ ostContextEntity: OstContextEntity) {
        Logger.log(message: "flowComplete", parameterToPrint: (ostContextEntity.entity as! OstBaseEntity).data)
        
        switch ostContextEntity.type {
        case .setupDevice:
            let currentDevice: OstCurrentDevice  = ostContextEntity.entity as! OstCurrentDevice
            let user: OstUser = try! OstUser.getById(currentDevice.userId!)!
            _ = try! ActivateUser(userId: user.id, tokenId: user.tokenId!, mappyUserId: mappyUserId, pin: "123456", password: "fjkaefbhawebkfkuhwabfuwaebfyu3bfyubruq23h87hriuq3hrniuq").perform()
//            AddDevice(mappyUserId: mappyUserId, userId: user.id).perform()
        default:
            return
        }
    }
    
    func flowInterrupt(_ ostError: OstError) {
        
    }
    
    func determineAddDeviceWorkFlow(_ ostAddDeviceFlowProtocol: OstAddDeviceFlowProtocol) {
        
    }
    
    func showQR(_ startPollingProtocol: OstStartPollingProtocol, image qrImage: CIImage) {
        
    }
    
    func getWalletWords(_ ostWalletWordsAcceptProtocol: OstWalletWordsAcceptProtocol) {
        
    }
    
    func invalidWalletWords(_ ostWalletWordsAcceptProtocol: OstWalletWordsAcceptProtocol) {
        
    }
    
    func walletWordsValidated() {
        
    }
}
