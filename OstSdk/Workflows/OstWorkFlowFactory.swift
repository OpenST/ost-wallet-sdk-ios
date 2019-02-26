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
    public class func setupDevice(userId: String, tokenId: String, forceSync: Bool = false, delegate: OstWorkFlowCallbackProtocol) {
        let registerDeviceObj = OstRegisterDevice(userId: userId, tokenId: tokenId, forceSync: forceSync, delegat: delegate)
        registerDeviceObj.perform()
    }
    
    /// Once device setup is completed, call active user to deploy token holder.
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - pin: user secret pin.
    ///   - password: App-server secret for user.
    ///   - spendingLimit: Max amount that user can spend per transaction.
    ///   - expirationHeight:
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func activateUser(userId: String, pin: String, password: String, spendingLimit: String,
                                   expirationHeight: Int, delegate: OstWorkFlowCallbackProtocol) {
        let activateUserObj = OstActivateUser(userId: userId, pin: pin, password: password, spendingLimit: spendingLimit, expirationHeight: expirationHeight, delegate: delegate)
        activateUserObj.perform()
    }
    
    /// Add device
    ///
    /// - Parameters:
    ///   - userId: Ost user identifier.
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func addDevice(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        let addDeviceObject = OstAddDevice(userId: userId, delegate: delegate)
        addDeviceObject.perform()
    }
  
  /// Add session for user.
  ///
  /// - Parameters:
  ///   - userId: Kit user id
  ///   - spendingLimit: Amount user can spend in a transaction.
  ///   - expiresAfter: Seconds after which the session key should expire.
  ///   - delegate: Callback for action complete or to perform respective action
  public class func addSession(userId: String, spendingLimit: String, expiresAfter: TimeInterval, delegate: OstWorkFlowCallbackProtocol) {
    let ostAddSession = OstAddSession(userId: userId, spendingLimit: spendingLimit, expiresAfter: expiresAfter, delegate: delegate)
    ostAddSession.perform()
  }
    
    /// Perform operations for given QR-Code image of core image type.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - qrCodeCoreImage: QR-Code image of Core Image type
    ///   - delegate: Callback for action complete or to perform respective action
    public class func perform(userId: String, ciImage qrCodeCoreImage: CIImage, delegate: OstWorkFlowCallbackProtocol) {
        let payload: [String]? = qrCodeCoreImage.readQRCode
        if (payload == nil || payload!.count == 0) {
            delegate.flowInterrupted(OstError.init("w_wff_p_1", .qrReadFailed))
        }
        self.perfrom(userId: userId, payload: payload!.first!, delegate: delegate)
    }
    
    /// Perform operations for given QR-Code image.
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - qrCodeImage: QR-Code image.
    ///   - delegate: Callback for action complete or to perform respective action
    public class func pefrom(userId: String, image qrCodeImage: UIImage, delegate: OstWorkFlowCallbackProtocol) {
        
    }
    
    ///  Perform operations for given paylaod
    ///
    /// - Parameters:
    ///   - userId: Kit user id.
    ///   - payload: Json string of payload is expected.
    ///   - delegate: Callback for action complete or to perform respective action
    public class func perfrom(userId: String, payload: String, delegate: OstWorkFlowCallbackProtocol) {
        let performObj = OstPerform(userId: userId, payload: payload, delegate: delegate)
        performObj.perform()
    }
    
    /// Get paper wallet of given user id.
    ///
    /// - Parameters:
    ///   - userId: Kit user id
    ///   - delegate: Callback for action complete or to perform respective action.
    public class func getPaperWallet(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        let paperWalletObj = OstGetPapaerWallet(userId: userId, delegate: delegate)
        paperWalletObj.perform()
    }
}
