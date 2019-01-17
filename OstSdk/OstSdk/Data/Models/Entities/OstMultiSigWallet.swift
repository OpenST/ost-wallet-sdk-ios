//
//  OstMultiSigWalletEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import EthereumKit

public class OstMultiSigWallet: OstBaseEntity {
   
}

public extension OstMultiSigWallet {
    var local_entity_id : String? {
        return data["local_entity_id"] as? String ?? nil
    }
    
    var address : String? {
        return data["address"] as? String ?? nil
    }
    
    var multi_sig_id : String? {
        return data["multi_sig_id"] as? String ?? nil
    }
    
    var user_id : String? {
        return data["user_id"] as? String ?? nil
    }
}


public extension OstMultiSigWallet {
    
    public final class Transaction {
        var rawTransaction: RawTransaction
        public init(nonce: Int, value: String, to: String, gasPrice: Int, gasLimit: Int) throws {
            let wei:BInt = try Converter.toWei(ether: value)
            self.rawTransaction = RawTransaction(value: wei, to: to, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce)
        }
    }
    
    public func signTransaction(_ transaction: OstMultiSigWallet.Transaction) throws -> String {
        guard let secureKey: OstSecureKey = try OstSecureKey.getSecKey(for: self.address!) else {
            throw OstError.actionFailed("Sign Transaction failed to perform")
        }
        
        let privateKey: String = String(data: secureKey.secData, encoding: .utf8)!
        let wallet: Wallet = Wallet(network: .mainnet, privateKey: privateKey, debugPrints: true)
        return try wallet.sign(rawTransaction: transaction.rawTransaction)
    }
}
