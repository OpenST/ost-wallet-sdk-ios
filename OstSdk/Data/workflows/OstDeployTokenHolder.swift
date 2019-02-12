//
//  OstDeployTokenHolder.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstDeployTokenHolder: OstWorkflowBase, OstPinAcceptProtocol, OstDeviceRegisteredProtocol {
    let ostRegisterDeviceThread = DispatchQueue(label: "com.ost.sdk.OstDeployTokenHolder", qos: .background)
    
    var delegate: OstWorkFlowCallbackProtocol
    
    var spendingLimit: String
    var expirationHeight: String
    
    var user: OstUser? = nil
    var currentDevice: OstCurrentDevice? = nil
    var walletKeys: OstWalletKeys? = nil
    
    
    init(userId: String, spendingLimit: String, expirationHeight: String, delegate: OstWorkFlowCallbackProtocol) {
        self.spendingLimit = spendingLimit
        self.expirationHeight = expirationHeight
        
        self.delegate = delegate
        
        super.init(userId: userId)
    }
    
    override func perform() {
        ostRegisterDeviceThread.sync {
            do {
                user = try getUser()
                if (user == nil) {
                    self.delegate.flowInterrupt(OstError.actionFailed("user is not present."))
                    return
                }
                
                currentDevice = user!.getCurrentDevice()
                if (currentDevice == nil) {
                    self.delegate.flowInterrupt(OstError.actionFailed("active device is not present."))
                    return
                }
                
                let walletKeys: OstWalletKeys = try OstCryptoImpls().generateCryptoKeys()
                let sessionKeyInfo: OstSessionKeyInfo = try currentDevice!.encrypt(privateKey: walletKeys.privateKey!)
                
                var ostSecureKey = OstSecureKey(address: walletKeys.address!, privateKeyData: sessionKeyInfo.sessionKeyData, isSecureEnclaveEnrypted: sessionKeyInfo.isSecureEnclaveEncrypted)
                ostSecureKey = OstSecureKeyRepository.sharedSecureKey.insertOrUpdateEntity(ostSecureKey) as! OstSecureKey
               
            }catch let error{
                DispatchQueue.main.async {
                    self.delegate.flowInterrupt(error as! OstError)
                }
            }
        }
    }
    
    func getTokenHolderDeploymentParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["device_addresses"] = 
        params[""] = walletKeys?.address!
        return params
    }
    
    //MARK: - OstPinAcceptProtocol
    public func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        
    }
    
    //MARK: - OstDeviceRegisteredProtocol
    public func deviceRegistered(_ apiResponse: [String : Any]) {
        
    }
}
