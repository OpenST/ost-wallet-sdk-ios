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
    
    let dispatchGroup: DispatchGroup = DispatchGroup()
    
    var chainInfo: [String: Any]? = nil
    var sessionAddress: String? = nil
    var expirationHeight: Int = 0
    var error: OstError? = nil
    
    var onSuccess: ((SessionHelper) -> Void)? = nil
    var onFailure: ((OstError) -> Void)? = nil
    
    let expiresAfter: TimeInterval
    init(userId: String, expiresAfter: TimeInterval) {
        self.expiresAfter = expiresAfter
        
        super.init(userId: userId)
    }
    
    func getSessionData(onSuccess: @escaping ((SessionHelper) -> Void), onFailure: @escaping ((OstError) -> Void)) {
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        do {
            try generateSessionKeys()
            try fetchChainInfo()
        }catch let error{
            onFailure(error as! OstError)
        }
    }
    
    private func generateSessionKeys() throws {
        let keyMananger = OstKeyManager(userId: self.userId)
        self.sessionAddress = try keyMananger.createSessionKey()
    }
    
    private func fetchChainInfo() throws {
//        self.dispatchGroup.enter()
        try OstAPIChain(userId: self.userId).getChain(onSuccess: { (chainInfo) in
            self.chainInfo = chainInfo
            self.calcuateExpirationHeight()
//            self.dispatchGroup.leave()
        }) { (error) in
            self.error = error
            self.onFailure?(error)
//            self.dispatchGroup.leave()
        }
//        self.dispatchGroup.wait()
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
        
        let sessionHelper: SessionHelper = (self.sessionAddress!, OstUtils.toString(self.expirationHeight)!)
        self.onSuccess?(sessionHelper)
    }
}
