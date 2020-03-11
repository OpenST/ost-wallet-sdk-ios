/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

let CHAIN_BLOCK_HEIGHT = "block_height"
let CHAIN_BLOCK_TIME = "block_time"

class OstSessionHelper: OstWorkflowHelperBase {
    typealias SessionData = (sessionAddress: String, expirationHeight: String)
    typealias MultipleSessionData = (sessionAddresses: [String], expirationHeight: String)
    
    private let expiresAfter: TimeInterval
    private let spendingLimit: String
    
    private var chainInfo: [String: Any]? = nil
    private var expirationHeight: Int = 0
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - userId: User Id
    ///   - expiresAfter: Relative time
    ///   - spendingLimit: Spending limit
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
    func getSessionData() throws -> SessionData {
        try fetchChainInfo()
        calcuateExpirationHeight()
        let sessionAddress = try setupSessionEnity()
        return (sessionAddress, OstUtils.toString(self.expirationHeight)!)
    }
    
    func getMultipleSesssionData(sessionCount: Int) throws -> MultipleSessionData {
        try fetchChainInfo()
        calcuateExpirationHeight()
        
        var sessionAddresses = [String]()
        for _ in 0..<sessionCount {
            let sessionAddress = try setupSessionEnity()
            sessionAddresses.append(sessionAddress)
        }
        
        return (sessionAddresses, OstUtils.toString(self.expirationHeight)!)
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
    
    
    /// Setup session entity.
    ///
    /// - Returns: Session Address
    func setupSessionEnity() throws -> String {
        let sessionAddress = try getNewSessionAddress()
        let params = getSessionEntityParams(for: sessionAddress)
        try OstSession.storeEntity(params)
        
        return sessionAddress
    }
    
    /// Create session keys
    ///
    /// - Throws: OstError
    func getNewSessionAddress() throws -> String {
        let sessionAddress = try OstKeyManagerGateway
            .getOstKeyManager(userId: self.userId)
            .createSessionKey()
        
        return sessionAddress
    }
    
    /// Get session entity data
    ///
    /// - Returns: entity dictionary
    private func getSessionEntityParams(for sessionAddress: String) -> [String: Any] {
        var params: [String: Any] = [:]
        params["user_id"] = self.userId
        params["address"] = sessionAddress
        params["expiration_height"] = self.expirationHeight
        params["spending_limit"] = self.spendingLimit
        params["nonce"] = 0
        params["status"] = OstSession.Status.CREATED.rawValue
        
        return params
    }
}
