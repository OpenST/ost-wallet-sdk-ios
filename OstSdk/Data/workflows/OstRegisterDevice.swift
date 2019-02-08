//
//  OstRegisterDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstRegisterDevice: OstWorkflowBase, OstDeviceRegisteredProtocol {

    let ostRegisterDeviceThread = DispatchQueue(label: "com.ost.sdk.OstRegisterDevice", qos: .background)
    var delegate: OstWorkFlowCallbackProtocol
    var keyManager: OstKeyManager
    
    public init(userId: String, tokenId: String, delegat: OstWorkFlowCallbackProtocol) throws {
        self.delegate = delegat
        keyManager = try OstKeyManager(userId: userId)
        
        super.init(userId: userId)
    }
    
    override func perform() {
        ostRegisterDeviceThread.async {
            if self.hasRegisteredDevice() {
                DispatchQueue.main.async {
                    self.delegate.flowComplete(OstContextEntity(type: .registerDevice))
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
    
    //MARK: - Private
    func hasRegisteredDevice() -> Bool {
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
    
    func getRegisterDeviceRequestParams() throws -> [String: Any] {
        let deviceAddress = try keyManager.createKeyWithMnemonics()
        let apiAddress = try keyManager.createAPIKey()
        
        var apiParam: [String: Any] = [:]
        apiParam["address"] = deviceAddress
        apiParam["api_signer_address"] = apiAddress
        apiParam["device_uuid"] = getDeviceUUID() ?? ""
        apiParam["device_name"] = getDeviceName()
        apiParam["updated_timestamp"] = OstUtils.toString(Date.negativeTimestamp())
        
        _ = try OstDevice.parse(apiParam)
        return apiParam
    }
    
    func getDeviceUUID() -> String? {
        return UIDevice.current.identifierForVendor?.uuidString
    }
    
    func getDeviceName() -> String {
        return UIDevice.current.name
    }
    
    //MARK: - OstDeviceRegisteredProtocol
    public func deviceRegistered(_ apiResponse: [String : Any]) throws {
        if let deviceJSON = apiResponse["device"] as? [String : Any] {
            let ostDevice: OstDevice = try OstDevice.parse(deviceJSON)!
            delegate.flowComplete(OstContextEntity(type: .registerDevice, entity: ostDevice))
            return
        }
        delegate.flowInterrupt(OstError.invalidInput("api response is not as desired."))
    }
    
    public func cancelFlow(_ cancelReason: String) {
        
    }
}
