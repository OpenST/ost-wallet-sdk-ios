//
//  OstWorkFlowFactory.swift
//  OstSdk
//
//  Created by aniket ayachit on 31/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

extension OstSdk {
    //MARK: - Workflow
    
    /// setup device for user.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - tokenId: Token identifier for user.
    ///   - forceSync: Force sync data from server.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func setupDevice(
        userId: String,
        tokenId: String,
        forceSync: Bool = false,
        delegate: OstWorkFlowCallbackDelegate) {
        
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
    ///   - pin: user secret pin.
    ///   - passphrasePrefix: App-server secret for user.
    ///   - spendingLimitInWei: Max amount that user can spend per transaction.
    ///   - expireAfterInSec: Session expiration time in seconds.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func activateUser(
        userId: String,
        pin: String,
        passphrasePrefix: String,
        spendingLimitInWei: String,
        expireAfterInSec: TimeInterval,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let activateUserObj = OstActivateUser(
            userId: userId,
            pin: pin,
            passphrasePrefix: passphrasePrefix,
            spendingLimit: spendingLimitInWei,
            expireAfter: expireAfterInSec,
            delegate: delegate)
        
        activateUserObj.perform()
    }
    
    /// Add device Using mnemonicss.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func addDeviceUsingMnemonics(
        userId: String,
        mnemonics: [String],
        delegate: OstWorkFlowCallbackDelegate) {
        
        let addDeviceObject = OstAddDeviceWithMnemonics(
            userId: userId,
            mnemonics: mnemonics,
            delegate: delegate)
        
        addDeviceObject.perform()
    }
    
    /// Add device
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func addDeviceWithMnemonicsString(
        userId: String,
        mnemonics: String,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let mnemonicsArray = mnemonics.components(separatedBy: " ")
        self.addDeviceUsingMnemonics(userId: userId,
                                     mnemonics: mnemonicsArray,
                                     delegate: delegate)
    }
    
    /// Add session for user.
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - spendingLimitInWei: Amount user can spend in a transaction.
    ///   - expireAfterInSec: Seconds after which the session key should expire.
    ///   - delegate: Callback for action complete or to perform respective action
    public class func addSession(
        userId: String,
        spendingLimitInWei: String,
        expireAfterInSec: TimeInterval,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let ostAddSession = OstAddSession(
            userId: userId,
            spendingLimit: spendingLimitInWei,
            expireAfter: expireAfterInSec,
            delegate: delegate)
        
        ostAddSession.perform()
    }
    
    ///  Perform operations for given paylaod
    ///
    /// - Parameters:
    ///   - userId: User id.
    ///   - payload: Json string of payload is expected.
    ///   - delegate: Callback for action complete or to perform respective action
    public class func perfrom(
        userId: String,
        payload: String,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let performObj = OstPerform(userId: userId, payload: payload, delegate: delegate)
        performObj.perform()
    }
    
    /// Get paper wallet of given user id.
    ///
    /// - Parameters:
    ///   - userId: User id.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func getPaperWallet(
        userId: String,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let paperWalletObj = OstGetPaperWallet(userId: userId,
                                               delegate: delegate)
        paperWalletObj.perform()
    }
    
    /// Get QR-Code to add device.
    ///
    /// - Parameter userId: User id.
    /// - Returns: Core image of QR-Code.
    /// - Throws: OstError
    public class func getAddDeviceQRCode(
        userId: String) throws -> CIImage? {
        
        guard let user = try OstUser.getById(userId) else {
            throw OstError("w_wff_gadqc_1", .userNotFound)
        }
        
        if user.isStatusCreated {
            throw OstError("w_wff_gadqc_2", .userNotActivated)
        }
        guard let currentDevice = user.getCurrentDevice() else {
            throw OstError("w_wff_gadqc_3", .deviceNotset)
        }
        
        if !currentDevice.isStatusRegistered {
            throw OstError("w_wff_gadqc_4", .deviceNotRegistered)
        }
        let QRCodePaylaod: [String : Any] = ["dd": OstQRCodeDataDefination.AUTHORIZE_DEVICE.rawValue,
                                             "ddv": 1.0,
                                             "d":["da":currentDevice.address!]]
        let qrCodePayloadString: String = try OstUtils.toJSONString(QRCodePaylaod)!
        
        return qrCodePayloadString.qrCode
    }
    
    /// Start polling for entity id.
    ///
    /// - Parameters:
    ///   - userId: User id.
    ///   - entityId: entity id to start polling for.
    ///   - entityType: type of entity.
    ///   - delegate: Callback for action complete or to perform respective actions.
    fileprivate class func poll(
        userId: String,
        entityId: String,
        entityType: OstPollingEntityType,
        delegate: OstWorkFlowCallbackDelegate ) {
        
        let pollingObj = OstPolling(userId: userId,
                                    entityId: entityId,
                                    entityType: entityType,
                                    delegate: delegate)
        pollingObj.perform()
    }
    
    /// Initialize recover device.
    ///
    /// - Parameters:
    ///   - userId: User id.
    ///   - recoverDeviceAddress: Device address of device tobe recovered.
    ///   - uPin: User pin.
    ///   - passphrasePrefix: Application passphrase prefix provied by application server.
    ///   - delegate: Callback for action complete or to perform respective actions.
    public class func initializeRecoverDevice(
        userId: String,
        recoverDeviceAddress: String,
        uPin: String,
        passphrasePrefix: String,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let recoverDeviceInitialize = OstRecoverDevice(userId: userId,
                                                       deviceAddressToRecover: recoverDeviceAddress,
                                                       uPin: uPin,
                                                       passphrasePrefix: passphrasePrefix,
                                                       delegate: delegate)
        recoverDeviceInitialize.perform()
    }
    
    /// Reset pin
    ///
    /// - Parameters:
    ///   - userId: User id.
    ///   - passphrasePrefix: application passphrase prefix provied by application server.
    ///   - oldPin: old pin.
    ///   - newPin: new pin.
    ///   - delegate: Callback for action complete or to perform respective actions.
    public class func resetPin(
        userId: String,
        passphrasePrefix: String,
        oldPin: String,
        newPin: String,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let resetPinWorkFlow = OstResetPin(
            userId: userId,
            passphrasePrefix: passphrasePrefix,
            oldPin: oldPin,
            newPin: newPin,
            delegate: delegate)
        
        resetPinWorkFlow.perform()
    }
    
    /// Execute transaction
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - tokenHolderAddresses: Addresses to transfer fund
    ///   - amounts: anounts to transfer
    ///   - transactionType: Type of transaction to execute. Either ExecuteTransactionTypeDirectTransfer or ExecuteTransactionTypePay
    ///   - tokenId: token id
    ///   - delegate: Callback
    public class func executeTransaction(
        userId: String,
        tokenHolderAddresses: [String],
        amounts: [String],
        transactionType: OstExecuteTransactionType,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let executeTransactionFlow = OstExecuteTransaction(
            userId: userId,
            ruleName: transactionType.rawValue,
            toAddresses: tokenHolderAddresses,
            amounts: amounts,
            delegate: delegate)
        
        executeTransactionFlow.perform()
    }
}
