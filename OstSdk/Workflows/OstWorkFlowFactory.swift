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
    ///   - forceSync: Force sync data from Kit.
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
    ///   - password: App-server secret for user.
    ///   - spendingLimit: Max amount that user can spend per transaction.
    ///   - expireAfter: Session expiration time.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func activateUser(
        userId: String,
        pin: String,
        password: String,
        spendingLimit: String,
        expireAfter: TimeInterval,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let activateUserObj = OstActivateUser(
            userId: userId,
            pin: pin, password:
            password,
            spendingLimit: spendingLimit,
            expireAfter: expireAfter,
            delegate: delegate)
        
        activateUserObj.perform()
    }
    
    /// Add device with mnemonicss.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func addDeviceWithMnemonics(
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
        self.addDeviceWithMnemonics(userId: userId,
                                    mnemonics: mnemonicsArray,
                                    delegate: delegate)
    }
    
    /// Add session for user.
    ///
    /// - Parameters:
    ///   - userId: Kit user id
    ///   - spendingLimit: Amount user can spend in a transaction.
    ///   - expiresAfter: Seconds after which the session key should expire.
    ///   - delegate: Callback for action complete or to perform respective action
    public class func addSession(
        userId: String,
        spendingLimit: String,
        expireAfter: TimeInterval,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let ostAddSession = OstAddSession(
            userId: userId,
            spendingLimit: spendingLimit,
            expireAfter: expireAfter,
            delegate: delegate)
        
        ostAddSession.perform()
    }
    
    /// Perform operations for given QR-Code image of core image type.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - qrCodeCoreImage: QR-Code image of Core Image type
    ///   - delegate: Callback for action complete or to perform respective action
    public class func perform(
        userId: String,
        ciImage qrCodeCoreImage: CIImage,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let payload: [String]? = qrCodeCoreImage.readQRCode
        
        //Note: Validations have been moved inside.
        //This is done to trigger flowInterupt; IMHO; the proper way.
        self.perfrom(userId: userId, payload: payload!.first!, delegate: delegate)
    }
    
    ///  Perform operations for given paylaod
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
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
    ///   - userId: Kit user id.
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
    /// - Parameter userId: Kit user id.
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
    ///   - userId: Kit user id.
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
    ///   - userId: Kit user id.
    ///   - recoverDeviceAddress: device address of device tobe recovered.
    ///   - uPin: user pin.
    ///   - password: application password provied by application server.
    ///   - delegate: Callback for action complete or to perform respective actions.
    public class func initializeRecoverDevice(
        userId: String,
        recoverDeviceAddress: String,
        uPin: String,
        password: String,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let recoverDeviceInitialize = OstRecoverDevice(userId: userId,
                                                       deviceAddressToRecover: recoverDeviceAddress,
                                                       uPin: uPin,
                                                       password: password,
                                                       delegate: delegate)
        recoverDeviceInitialize.perform()
    }
    
    //TODO: Update README
    /// Abort recover device.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - uPin: user pin.
    ///   - password: application password provied by application server.
    ///   - delegate: Callback for action complete or to perform respective actions.
//  fileprivate class func abortRecoverDevice(
//        userId: String,
//        uPin: String,
//        password: String,
//        delegate: OstWorkFlowCallbackDelegate) {
//
//        let recoverDeviceAbort = OstAbortRecoverDevice(userId: userId,
//                                                       uPin: uPin,
//                                                       password: password,
//                                                       delegate: delegate)
//        recoverDeviceAbort.perform()
//    }
    
    /// Reset pin
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - password: application password provied by application server.
    ///   - oldPin: old pin.
    ///   - newPin: new pin.
    ///   - delegate: Callback for action complete or to perform respective actions.
    public class func resetPin(
        userId: String,
        password: String,
        oldPin: String,
        newPin: String,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let resetPinWorkFlow = OstResetPin(
            userId: userId,
            password: password,
            oldPin: oldPin,
            newPin: newPin,
            delegate: delegate)
        
        resetPinWorkFlow.perform()
    }
    
    /// Execute transaction
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - transactionType: Type of transaction to execute. Either ExecuteTransactionTypeDirectTransfer or ExecuteTransactionTypePay
    ///   - toAddresses: Addresses to transfer fund
    ///   - amounts: anounts to transfer
    ///   - tokenId: token id
    ///   - delegate: Callback
    public class func executeTransaction(
        userId: String,
        transactionType: OstExecuteTransactionType,
        toAddresses: [String],
        amounts: [String],
        tokenId: String,
        delegate: OstWorkFlowCallbackDelegate) {
        
        let executeTransactionFlow = OstExecuteTransaction(
            userId: userId,
            ruleName: transactionType.rawValue,
            toAddresses: toAddresses,
            amounts: amounts,
            tokenId: tokenId,
            delegate: delegate)
        
        executeTransactionFlow.perform()
    }
}
