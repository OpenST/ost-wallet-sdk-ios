//
//  OstRegisterDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public class OstRegisterDevice: OstDeviceRegisteredProtocol {

    let ostRegisterDeviceThread = DispatchQueue(label: "com.ost.sdk.OstRegisterDevice", qos: .background)
    var userId: String
    var delegate: OstWorkFlowCallbackProtocol
    var keyManager: OstKeyManager
    
    public init(userId: String, delegat: OstWorkFlowCallbackProtocol) throws {
        self.userId = userId
        self.delegate = delegat
        keyManager = try OstKeyManager(userId: userId)
    }
    
    func perform(){
        ostRegisterDeviceThread.async {
            if self.hasRegisteredDevice() {
                DispatchQueue.main.async {
                    self.delegate.flowComplete(OstContextEntity())
                }
            }else {
                DispatchQueue.main.sync {
                    do {
                        let requestParams = try self.getRegisterDeviceRequestParams()
                        self.delegate.registerDevice(requestParams, delegate: self)
                    }catch let error{
                        self.delegate.flowInterrupt(error as! OstError)
                    }
                }
            }
        }
    }
    
    
    //MARK: - OstDeviceRegisteredProtocol
    public func deviceRegistered(_ apiResponse: [String : Any]) throws {
        if let deviceJSON = apiResponse["device"] as? [String : Any] {
            let ostDevice: OstDevice = try OstDevice.parse(deviceJSON)!
        }
    }
    
    public func cancelFlow(_ cancelReason: String) {
        
    }
    
    //MARK: - Private
    private func hasRegisteredDevice() -> Bool {
        do {
            if let deviceArray: [OstDevice] = try OstDevice.getDeviceByParentId(parentId: userId) {
                if let apiAddress = keyManager.getAPIAddress() {
                    for device in deviceArray {
                        if (device.personal_sign_address == apiAddress) &&
                            (device.status?.uppercased() == "REGISTERED"){
                                return true
                        }
                    }
                }
            }
        }catch { }
        return false
    }
    
    private func getRegisterDeviceRequestParams() throws -> [String: Any] {
        let deviceAddress = try keyManager.createKeyWithMnemonics()
        let apiAddress = keyManager.getAPIAddress()
        let uuid = getDeviceUUID()
        let deviceName = getDeviceName()
        return  ["address": deviceAddress,
                 "personal_sign_address": apiAddress!,
                 "device_uuid": uuid ?? "",
                 "device_name": deviceName]
    }
    
    private func getDeviceUUID() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    private func getDeviceName() -> String {
        return UIDevice.current.name
    }
}
