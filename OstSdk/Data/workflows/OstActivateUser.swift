//
//  OstDeployTokenHolder.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstActivateUser: OstWorkflowBase, OstPinAcceptProtocol, OstDeviceRegisteredProtocol {
    let ostRegisterDeviceThread = DispatchQueue(label: "com.ost.sdk.OstDeployTokenHolder", qos: .background)
    
    var uPin: String
    var password: String
    var spendingLimit: String
    var expirationHeight: String
    
    var salt: String = "salt"
    var user: OstUser? = nil
    var currentDevice: OstCurrentDevice? = nil
    var walletKeys: OstWalletKeys? = nil
    var recoveryAddreass: String? = nil
    
    init(userId: String, uPin: String, password: String, spendingLimit: String, expirationHeight: String, delegate: OstWorkFlowCallbackProtocol) {
        self.uPin = uPin
        self.password = password
        self.spendingLimit = spendingLimit
        self.expirationHeight = expirationHeight
        
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        ostRegisterDeviceThread.sync {
            do {
                user = try! getUser()!
                
                currentDevice = user!.getCurrentDevice()
                
                recoveryAddreass = getRecoveryKey()
                
                if (recoveryAddreass == nil) {
                    self.postError(OstError.actionFailed("recovery address formation failed."))
                    return
                }
                
                walletKeys = try OstCryptoImpls().generateCryptoKeys()
                let sessionKeyInfo: OstSessionKeyInfo = try currentDevice!.encrypt(privateKey: walletKeys!.privateKey!)
                
                var ostSecureKey = OstSecureKey(address: walletKeys!.address!, privateKeyData: sessionKeyInfo.sessionKeyData, isSecureEnclaveEnrypted: sessionKeyInfo.isSecureEnclaveEncrypted)
                ostSecureKey = OstSecureKeyRepository.sharedSecureKey.insertOrUpdateEntity(ostSecureKey) as! OstSecureKey
            
            }catch let error{
                    self.postError(error)
            }
        }
    }
    
    func getRecoveryKey() -> String? {
        do {
            return try OstCryptoImpls().generateRecoveryKey(pinPrefix: self.password, pin: self.uPin, pinPostFix: self.userId, salt: salt, n: OstConstants.OST_SCRYPT_N, r: OstConstants.OST_SCRYPT_R, p: OstConstants.OST_SCRYPT_P, size: OstConstants.OST_SCRYPT_DESIRED_SIZE_BYTES)
        }catch let error {
            self.postError(error)
            return nil
        }
    }
    
    func getActivateUserParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["spending_limit"] = self.spendingLimit
        params["recovery_address"] = self.recoveryAddreass!
        params["expiration_height"] = self.expirationHeight
        return params
    }
    
    //MARK: - OstPinAcceptProtocol
    public func pinEntered(_ uPin: String, applicationPassword appUserPassword: String) {
        
    }
    
    //MARK: - OstDeviceRegisteredProtocol
    public func deviceRegistered(_ apiResponse: [String : Any]) {
        
    }
}
