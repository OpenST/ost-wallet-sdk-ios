/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

extension OstWalletSdk {
    //MARK: - Workflow
    
    /// setup device for user.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - tokenId: Token identifier for user.
    ///   - forceSync: Force sync data from server.
    ///   - delegate: Callback for action complete or to perform respective action.
    @objc
    public class func setupDevice(
        userId: String,
        tokenId: String,
        forceSync: Bool = false,
        delegate: OstWorkflowDelegate) {
        
        let registerDeviceObj = OstRegisterDevice(
            userId: userId,
            tokenId: tokenId,
            forceSync: forceSync,
            delegate: delegate)
        
        registerDeviceObj.perform()
    }
    
    /// Once device setup is completed, call active user to deploy token holder.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - userPin: User secret pin.
    ///   - passphrasePrefix: App-server secret for user.
    ///   - spendingLimit: Max amount that user can spend per transaction
    ///   - expireAfterInSec: Session expiration time in seconds.
    ///   - delegate: Callback for action complete or to perform respective action.
    @objc
    public class func activateUser(
        userId: String,
        userPin: String,
        passphrasePrefix: String,
        spendingLimit: String,
        expireAfterInSec: TimeInterval,
        delegate: OstWorkflowDelegate) {
        
        let activateUserObj = OstActivateUser(
            userId: userId,
            userPin: userPin,
            passphrasePrefix: passphrasePrefix,
            spendingLimit: spendingLimit,
            expireAfter: expireAfterInSec,
            delegate: delegate)
        
        activateUserObj.perform()
    }
    
    /// Add device using mnemonics.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func authorizeCurrentDeviceWithMnemonics(
        userId: String,
        mnemonics: [String],
        delegate: OstWorkflowDelegate) {
        
        let addDeviceObject = OstAddDeviceWithMnemonics(
            userId: userId,
            mnemonics: mnemonics,
            delegate: delegate)
        
        addDeviceObject.perform()
    }
    
    /// Add session for user.
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - spendingLimit: Amount user can spend in a transaction
    ///   - expireAfterInSec: Seconds after which the session key should expire.
    ///   - delegate: Callback for action complete or to perform respective action
    public class func addSession(
        userId: String,
        spendingLimit: String,
        expireAfterInSec: TimeInterval,
        delegate: OstWorkflowDelegate) {
        
        let ostAddSession = OstAddSession(
            userId: userId,
            spendingLimit: spendingLimit,
            expireAfter: expireAfterInSec,
            delegate: delegate)
        
        ostAddSession.perform()
    }
    
    /// Perform operations for given paylaod
    ///
    /// - Parameters:
    ///   - userId: User id.
    ///   - payload: Json string of payload is expected.
    ///   - delegate: Callback for action complete or to perform respective action
    public class func performQRAction(
        userId: String,
        payload: String,
        delegate: OstWorkflowDelegate) {
        
        let performObj = OstPerform(userId: userId,
                                    payload: payload,
                                    delegate: delegate)
        performObj.perform()
    }
    
    /// Get device mnemonics of given user id.
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - delegate: Callback for action complete or to perform respective action
    public class func getDeviceMnemonics(
        userId: String,
        delegate: OstWorkflowDelegate) {
        
        let deviceMnemonicsObj = OstGetDeviceMnemonics(userId: userId,
                                                       delegate: delegate)
        deviceMnemonicsObj.perform()
    }
    
    /// Get QR-Code to add device.
    ///
    /// - Parameter userId: User id.
    /// - Returns: Core image of QR-Code.
    /// - Throws: OstError
    @objc
    public class func getAddDeviceQRCode(
        userId: String) throws -> CIImage {
        
        guard let user = try OstUser.getById(userId) else {
            throw OstError("w_wff_gadqc_1", .userNotFound)
        }
        
        if user.isStatusCreated {
            throw OstError("w_wff_gadqc_2", .userNotActivated)
        }
        guard let currentDevice = user.getCurrentDevice() else {
            throw OstError("w_wff_gadqc_3", .deviceNotSet)
        }
        
        if !currentDevice.isStatusRegistered {
            throw OstError("w_wff_gadqc_4", .deviceNotRegistered)
        }
        let QRCodePaylaod: [String : Any] = ["dd": OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue,
                                             "ddv": 1.0,
                                             "d":["da":currentDevice.address!]]
        let qrCodePayloadString: String = try OstUtils.toJSONString(QRCodePaylaod)!
        
        if ( nil != qrCodePayloadString.qrCode) {
            return qrCodePayloadString.qrCode!;
        }
        throw OstError("w_wff_gadqc_5", OstErrorText.unexpectedError );
    }
        
    /// Initiate device recovery.
    ///
    /// - Parameters:
    ///   - userId: User id.
    ///   - recoverDeviceAddress: Device address of device tobe recovered.
    ///   - userPin: User pin.
    ///   - passphrasePrefix: Application passphrase prefix provided by application server.
    ///   - delegate: Callback for action complete or to perform respective actions.
    @objc
    public class func initiateDeviceRecovery(
        userId: String,
        recoverDeviceAddress: String,
        userPin: String,
        passphrasePrefix: String,
        delegate: OstWorkflowDelegate) {
        
        let initiateDeviceRecoveryFlow = OstRecoverDevice(userId: userId,
                                                          deviceAddressToRecover: recoverDeviceAddress,
                                                          userPin: userPin,
                                                          passphrasePrefix: passphrasePrefix,
                                                          delegate: delegate)
        initiateDeviceRecoveryFlow.perform()
    }
    
    /// Abort device recovery.
    ///
    /// - Parameters:
    ///   - userId: User id.
    ///   - uPin: User pin.
    ///   - password: Application password provied by application server.
    ///   - delegate: Callback for action complete or to perform respective actions.
    @objc
    public class func abortDeviceRecovery(
        userId: String,
        userPin: String,
        passphrasePrefix: String,
        delegate: OstWorkflowDelegate) {
        
        let abortDeviceRecoveryFlow = OstAbortDeviceRecovery(userId: userId,
                                                             userPin: userPin,
                                                             passphrasePrefix: passphrasePrefix,
                                                             delegate: delegate)
        abortDeviceRecoveryFlow.perform()
    }
    
    /// Reset pin
    ///
    /// - Parameters:
    ///   - userId: User id.
    ///   - passphrasePrefix: Application passphrase prefix provided by application server.
    ///   - oldUserPin: Old user pin.
    ///   - newUserPin: New user pin.
    ///   - delegate: Callback for action complete or to perform respective actions.
    @objc
    public class func resetPin(
        userId: String,
        passphrasePrefix: String,
        oldUserPin: String,
        newUserPin: String,
        delegate: OstWorkflowDelegate) {
        
        let resetPinWorkFlow = OstResetPin(
            userId: userId,
            passphrasePrefix: passphrasePrefix,
            oldUserPin: oldUserPin,
            newUserPin: newUserPin,
            delegate: delegate)
        
        resetPinWorkFlow.perform()
    }
    
    /// Execute transaction
    ///````
    /// meta:
    /// [
    ///   "name":"Thanks for like",
    ///   "type": "user_to_user",
    ///   "details": "like"
    /// ]
    ///````
    /// - Parameters:
    ///   - userId: User id
    ///   - tokenHolderAddresses: Addresses to transfer fund
    ///   - amounts: Amounts to transfer
    ///   - transactionType: Type of transaction to execute. Either **ExecuteTransactionTypeDirectTransfer** or **ExecuteTransactionTypePay**.
    ///   - meta: Refer discussion for example
    ///     * name: Name of transaction
    ///     * type: It could be *user_to_user* or *company_to_user*
    ///   - delegate: Callback
    @objc
    public class func executeTransaction(
        userId: String,
        tokenHolderAddresses: [String],
        amounts: [String],
        transactionType: OstExecuteTransactionType,
        meta: [String: String],
        delegate: OstWorkflowDelegate) {
        
        let ruleName = transactionType.getQRText();
        let executeTransactionFlow = OstExecuteTransaction(
            userId: userId,
            ruleName: ruleName,
            toAddresses: tokenHolderAddresses,
            amounts: amounts,
            transactionMeta: meta,
            delegate: delegate)
        
        executeTransactionFlow.perform()
    }
    
    /// Logout all sessions
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - delegate: Callback
    @objc
    public class func logoutAllSessions(
        userId: String,
        delegate: OstWorkflowDelegate
        ) {
        
        let logoutAllSessionsFlow = OstLogoutAllSessions(userId: userId,
                                                         delegate: delegate)
        logoutAllSessionsFlow.perform()
    }
    
    @objc
    public class func revokeDevice(userId: String,
                                   deviceAddressToRevoke: String,
                                   delegate: OstWorkflowDelegate) {
        let revokeDeviceFlow = OstRevokeDeviceWithQRData(userId: userId,
                                                         deviceAddressToRevoke: deviceAddressToRevoke,
                                                         delegate: delegate)
        revokeDeviceFlow.perform()
    }
}
