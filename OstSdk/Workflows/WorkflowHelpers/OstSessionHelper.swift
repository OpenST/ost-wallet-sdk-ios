//
//  OstSessionHelper.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/03/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

let CHAIN_BLOCK_HEIGHT = "block_height"
let CHAIN_BLOCK_TIME = "block_time"

class OstSessionHelper: OstWorkflowHelperBase {
    typealias SessionData = (sessionAddress: String, expirationHeight: String)
    
    private let expiresAfter: TimeInterval
    private let spendingLimit: String
    
    private var chainInfo: [String: Any]? = nil
    private var sessionAddress: String? = nil
    private var expirationHeight: Int = 0
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - expiresAfter: Relative time
    ///   - spendingLimit: Spending limit in a Wei
    init(userId: String,
         expiresAfter: TimeInterval,
         spendingLimit: String) {
        
        self.expiresAfter = expiresAfter
        self.spendingLimit = spendingLimit
        super.init(userId: userId)
    }
    
    /// Get session address and expiration height
    ///
    /// - Returns: Session data
    /// - Throws: OstError
    func getSessionData() throws -> SessionData{
        try fetchChainInfo()
        calcuateExpirationHeight()
        try createSessionKeys()
        let params = getSessionEntityParams()
        try OstSession.storeEntity(params)

        return (self.sessionAddress!, OstUtils.toString(self.expirationHeight)!)
    }

    /// Fetch chain information from server
    ///
    /// - Throws: OstError
    private func fetchChainInfo() throws {
        var err: OstError? = nil
        let dispatchGroup: DispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        try OstAPIChain(userId: self.userId).getChain(onSuccess: { (chainInfo) in
            self.chainInfo = chainInfo
            dispatchGroup.leave()
        }) { (error) in
            err = error
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
        if (nil != err) {
            throw err!
        }
    }
    
    /// Calculate expiration height from relative value and chain information
    private func calcuateExpirationHeight() {
        let currentBlockHeight = OstUtils.toInt(self.chainInfo![CHAIN_BLOCK_HEIGHT])!
        let blockGenerationTime = OstUtils.toInt(self.chainInfo![CHAIN_BLOCK_TIME])!
        let bufferedSessionTime = OstConfig.getSessionBufferTime() + self.expiresAfter
        let validForBlocks = Int( bufferedSessionTime/Double(blockGenerationTime) )
        self.expirationHeight = validForBlocks + currentBlockHeight;
    }
    
    /// Create session keys
    ///
    /// - Throws: OstError
    private func createSessionKeys() throws {
        let keyMananger = OstKeyManager(userId: self.userId)
        self.sessionAddress = try keyMananger.createSessionKey()
    }
    
    /// Get session entity data
    ///
    /// - Returns: entity dictionary
    private func getSessionEntityParams() -> [String: Any] {
        var params: [String: Any] = [:]
        params["user_id"] = self.userId
        params["address"] = self.sessionAddress!
        params["expiration_height"] = self.expirationHeight
        params["spending_limit"] = self.spendingLimit
        params["nonce"] = 0
        params["status"] = OstSession.Status.CREATED.rawValue
        
        return params
    }
}
