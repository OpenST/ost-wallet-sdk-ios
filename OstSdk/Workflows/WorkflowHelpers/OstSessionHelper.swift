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
    typealias SessionHelper = (sessionAddress: String, expirationHeight: String)
    
    static let SESSION_BUFFER_TIME = Double(1 * 60 * 60); //1 Hour.
    
    var chainInfo: [String: Any]? = nil
    var sessionAddress: String? = nil
    var expirationHeight: Int = 0
    var error: OstError? = nil
    let spendingLimit: String
//
//    var onSuccess: ((SessionHelper) -> Void)? = nil
//    var onFailure: ((OstError) -> Void)? = nil
    
    let expiresAfter: TimeInterval
    init(userId: String, expiresAfter: TimeInterval, spendingLimit: String) {
        self.expiresAfter = expiresAfter
        self.spendingLimit = spendingLimit
        super.init(userId: userId)
    }
    
//    func getSessionData(onSuccess: @escaping ((SessionHelper) -> Void), onFailure: @escaping ((OstError) -> Void)) {
//        self.onSuccess = onSuccess
//        self.onFailure = onFailure
//        do {
//            try generateSessionKeys()
//            try fetchChainInfo()
//        }catch let error{
//            onFailure(error as! OstError)
//        }
//    }
    
    func getSessionData() throws -> SessionHelper{
        try generateSessionKeys()
        try fetchChainInfo()
        calcuateExpirationHeight()
        try generateAndSaveSessionEntity()

        return (self.sessionAddress!, OstUtils.toString(self.expirationHeight)!)
    }
    
    private func generateSessionKeys() throws {
        let keyMananger = OstKeyManager(userId: self.userId)
        self.sessionAddress = try keyMananger.createSessionKey()
    }
    
    private func fetchChainInfo() throws {
        let dispatchGroup: DispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        try OstAPIChain(userId: self.userId).getChain(onSuccess: { (chainInfo) in
            self.chainInfo = chainInfo
//            self.calcuateExpirationHeight()
            dispatchGroup.leave()
        }) { (error) in
            self.error = error
//            self.onFailure?(error)
            dispatchGroup.leave()
        }
        dispatchGroup.wait()
//        if (nil != self.error) {
//            throw self.error!
//        }
    }
    
    private  func calcuateExpirationHeight() {
        let currentBlockHeight = OstUtils.toInt(self.chainInfo![CHAIN_BLOCK_HEIGHT])!
        let blockGenerationTime = OstUtils.toInt(self.chainInfo![CHAIN_BLOCK_TIME])!
        let bufferedSessionTime = OstSessionHelper.SESSION_BUFFER_TIME + self.expiresAfter
        let validForBlocks = Int( bufferedSessionTime/Double(blockGenerationTime) )
        self.expirationHeight = validForBlocks + currentBlockHeight;
        
//        let sessionHelper: SessionHelper = (self.sessionAddress!, OstUtils.toString(self.expirationHeight)!)
//        self.onSuccess?(sessionHelper)
    }
    
    func generateAndSaveSessionEntity() throws {
        let params = self.getSessionEnityParams()
        try OstSession.storeEntity(params)
    }
    
    func getSessionEnityParams() -> [String: Any] {
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
