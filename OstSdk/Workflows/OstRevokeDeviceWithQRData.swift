//
//  OstRevokeDevice.swift
//  OstSdk
//
//  Created by aniket ayachit on 11/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstRevokeDeviceWithQRData: OstWorkflowBase, OstValidateDataDelegate {
    static private let PAYLOAD_DEVICE_ADDRESS_KEY = "da"

    class func getRevokeDeviceParamsFromQRPayload(_ payload: [String: Any?]) throws -> String {
        guard let deviceAddress: String = payload[OstRevokeDeviceWithQRData.PAYLOAD_DEVICE_ADDRESS_KEY] as? String else {
            throw OstError("w_rd_gadpfqrp_1", .invalidQRCode)
        }
        if deviceAddress.isEmpty {
            throw OstError("w_rd_gadpfqrp_2", .invalidQRCode)
        }
        return deviceAddress
    }

    private let ostRevokeDeviceQueue = DispatchQueue(label: "com.ost.sdk.OstRevokeDevice", qos: .background)
    private let workflowTransactionCountForPolling = 1
    private let deviceAddressToRevoke: String

    private var deviceToRevoke: OstDevice? = nil

    /// Initialize
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - deviceAddressToRevoke: Device address to revoke
    ///   - delegate: Callback
    init(userId: String,
         deviceAddressToRevoke: String,
         delegate: OstWorkFlowCallbackDelegate) {

        self.deviceAddressToRevoke = deviceAddressToRevoke
        super.init(userId: userId, delegate: delegate)
    }

    /// Get workflow Queue
    ///
    /// - Returns: DispatchQueue
    override func getWorkflowQueue() -> DispatchQueue {
        return self.ostRevokeDeviceQueue
    }

    /// Validate params.
    ///
    /// - Throws: OstError
    override func validateParams() throws {
        try super.validateParams()
        try self.workFlowValidator!.isUserActivated()
        try self.workFlowValidator!.isDeviceAuthorized()

        if (self.deviceAddressToRevoke.caseInsensitiveCompare(self.currentDevice!.address!) == .orderedSame){
            throw OstError("w_adwqrd_fd_2", OstErrorText.processSameDevice)
        }
    }

    /// Process
    ///
    /// - Throws: OstError
    override func process() throws {
        try fetchDevice()
        verifyData()
    }

    /// Fetch device to validate mnemonics
    ///
    /// - Throws: OstError
    private func fetchDevice() throws {
        var error: OstError? = nil
        let group = DispatchGroup()
        group.enter()
        try OstAPIDevice(userId: userId)
            .getDevice(deviceAddress: self.deviceAddressToRevoke,
                       onSuccess: { (ostDevice) in
                        self.deviceToRevoke = ostDevice
                        group.leave()
            }) { (ostError) in
                error = ostError
                group.leave()
        }
        group.wait()

        if (nil != error) {
            throw error!
        }
        if (nil == self.deviceToRevoke?.linkedAddress) {
            throw OstError("w_rd_fd_1", OstErrorText.linkedAddressNotFound)
        }
        
        if (!self.deviceToRevoke!.isStatusAuthorized) {
            throw OstError("w_rd_fd_2", OstErrorText.deviceNotAuthorized)
        }
        if (self.deviceToRevoke!.userId!.caseInsensitiveCompare(self.currentDevice!.userId!) != .orderedSame){
            throw OstError("w_rd_fd_3", OstErrorText.differentOwnerDevice)
        }
    }

    /// verify device from user.
    ///
    /// - Parameter device: OstDevice entity.
    private func verifyData() {
        let workflowContext = OstWorkflowContext(workflowType: .addDeviceWithQRCode);
        let contextEntity: OstContextEntity = OstContextEntity(entity: self.deviceToRevoke!, entityType: .device)
        DispatchQueue.main.async {
            self.delegate.verifyData(workflowContext: workflowContext,
                                     ostContextEntity: contextEntity,
                                     delegate: self)
        }
    }

    /// Callback from user about data verified to continue.
    public func dataVerified() {
        let queue: DispatchQueue = getWorkflowQueue()
        queue.async {
            self.authenticateUser();
        }
    }

    /// proceed workflow after user authentication
    override func proceedWorkflowAfterAuthenticateUser() {
        let queue: DispatchQueue = getWorkflowQueue()
        queue.async {
            let generateSignatureCallback: ((String) -> (String?, String?)) = { (signingHash) -> (String?, String?) in
                do {
                    let keychainManager = OstKeyManager(userId: self.userId)
                    if let deviceAddress = keychainManager.getDeviceAddress() {
                        let signature = try keychainManager.signWithDeviceKey(signingHash)
                        return (signature, deviceAddress)
                    }
                    throw OstError("w_rd_pwfaau_1", .apiSignatureGenerationFailed);
                }catch {
                    return (nil, nil)
                }
            }

            let onSuccess: ((OstDevice) -> Void) = { (ostDevice) in
                self.postWorkflowComplete(entity: ostDevice)
            }

            let onFailure: ((OstError) -> Void) = { (error) in
                self.postError(error)
            }

            let onRequestAcknowledged: ((OstDevice) -> Void) = { (ostDevice) in
                self.postRequestAcknowledged(entity: ostDevice)
            }

            OstRevokeDevice(userId: self.userId,
                            linkedAddress: self.deviceToRevoke!.linkedAddress!,
                            deviceAddressToRevoke: self.deviceToRevoke!.address!,
                            generateSignatureCallback: generateSignatureCallback,
                            onRequestAcknowledged: onRequestAcknowledged,
                            onSuccess: onSuccess,
                            onFailure: onFailure).perform()
        }
    }

    /// Get current workflow context
    ///
    /// - Returns: OstWorkflowContext
    override func getWorkflowContext() -> OstWorkflowContext {
        return OstWorkflowContext(workflowType: .abortRecoverDevice)
    }

    /// Get context entity
    ///
    /// - Returns: OstContextEntity
    override func getContextEntity(for entity: Any) -> OstContextEntity {
        return OstContextEntity(entity: entity, entityType: .device)
    }
}
