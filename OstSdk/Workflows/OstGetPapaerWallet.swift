//
//  OstGetPapaerWallet.swift
//  OstSdk
//
//  Created by aniket ayachit on 21/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstGetPapaerWallet: OstWorkflowBase {
    let ostGetPapaerWalletThread = DispatchQueue(label: "com.ost.sdk.OstGetPapaerWallet", qos: .background)
    
    override init(userId: String, delegate: OstWorkFlowCallbackProtocol) {
        super.init(userId: userId, delegate: delegate)
    }
    
    override func perform() {
        ostGetPapaerWalletThread.async {
            do {
                let keychainManager = OstKeyManager(userId: self.userId)
                guard let walletKey: String = keychainManager.getDeviceAddress() else {
                    throw OstError.init("w_gpw_1", .paperWalletNotFound)
                }
                guard let mnemonics: [String] = try keychainManager.getDeviceMnemonics() else {
                    throw OstError.init("w_gpw_2", .mnemonicsNotFound)
                }
                
                let paperWalletString: String = mnemonics.joined(separator: " ")
                self.postFlowCompleteForGetPaperWallet(entity: paperWalletString)
                
            }catch let error {
                self.postError(error)
            }
        }
    }
    
    func postFlowCompleteForGetPaperWallet(entity: String?) {
        Logger.log(message: "OstAddSession flowComplete", parameterToPrint: entity)
        
        DispatchQueue.main.async {
            let contextEntity: OstContextEntity = OstContextEntity(type: .papaerWallet , entity: entity)
            self.delegate.flowComplete(contextEntity);
        }
    }
}
