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
        ostPinAcceptProtocol.pinEntered("123456", applicationPassword: "fjkaefbhawebkfkuhwabfuwaebfyu3bfyubruq23h87hriuq3hrniuq")
    }
    
    func invalidPin(_ userId: String, delegate ostPinAcceptProtocol: OstPinAcceptProtocol) {
        
    }
    
    func pinValidated(_ userId: String) {
        
    }
    
    func flowComplete(_ ostContextEntity: OstContextEntity) {
        switch ostContextEntity.type {
        case .setupDevice:
            Logger.log(message: "setupDevice flowComplete", parameterToPrint: (ostContextEntity.entity as! OstBaseEntity).data)
            
            let currentDevice: OstCurrentDevice  = ostContextEntity.entity as! OstCurrentDevice
            let user: OstUser = try! OstUser.getById(currentDevice.userId!)!
            
            if (user.isActivated() && currentDevice.status!.uppercased() == "REGISTERED") {
                AddDevice(mappyUserId: mappyUserId, userId: user.id).perform()
            }else {
                _ = try! ActivateUser(userId: user.id, tokenId: user.tokenId!, mappyUserId: mappyUserId, pin: "123456", password: "fjkaefbhawebkfkuhwabfuwaebfyu3bfyubruq23h87hriuq3hrniuq").perform()
            }
    
        case .activateUser:
            Logger.log(message: "activateUser flowComplete", parameterToPrint: (ostContextEntity.entity as! OstBaseEntity).data)
            
            let user: OstUser  = ostContextEntity.entity as! OstUser
            OstSdk.addSession(userId: user.id, spendingLimit: "10000000", expirationHeight: 12345612, delegate: self)
         
        case .papaerWallet:
            print("paperWallet : ", ostContextEntity.entity as! String)
        default:
            return
        }
    }
    
    func flowInterrupt(_ ostError: OstError) {
       
    }
    
    func determineAddDeviceWorkFlow(_ ostAddDeviceFlowProtocol: OstAddDeviceFlowProtocol) {
        
    }
    
    func showQR(_ startPollingProtocol: OstStartPollingProtocol, image qrImage: CIImage) {
//        OstSdk.perform(userId: , ciImage: <#T##CIImage#>, delegate: <#T##OstWorkFlowCallbackProtocol#>)
    }
    
    func getWalletWords(_ ostWalletWordsAcceptProtocol: OstWalletWordsAcceptProtocol) {
        
    }
    
    func invalidWalletWords(_ ostWalletWordsAcceptProtocol: OstWalletWordsAcceptProtocol) {
        
    }
    
    func walletWordsValidated() {
        
    }
}
