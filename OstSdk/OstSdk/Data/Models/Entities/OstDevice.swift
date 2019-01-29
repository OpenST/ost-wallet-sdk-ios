//
//  OstDeviceEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation
import EthereumKit

public class OstDevice: OstBaseEntity {
    
    static let OSTDEVICE_PARENTID = "user_id"
    
    static func parse(_ entityData: [String: Any?]) throws -> OstDevice? {
        return try OstDeviceRepository.sharedDevice.insertOrUpdate(entityData, forIdentifier: self.getEntityIdentifer()) as? OstDevice ?? nil
    }
    
    static func getEntityIdentifer() -> String {
        return "address"
    }
    
    override func getId(_ params: [String: Any]) -> String {
        return OstUtils.toString(params[OstDevice.getEntityIdentifer()])!
    }
    
    override func getParentId(_ params: [String: Any]) -> String? {
        return OstUtils.toString(params[OstDevice.OSTDEVICE_PARENTID])
    }
}

public extension OstDevice {
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


public extension OstDevice {
    
    public final class Transaction {
        var rawTransaction: RawTransaction
        public init(nonce: Int, value: String, to: String, gasPrice: Int, gasLimit: Int) throws {
            let wei:BInt = try Converter.toWei(ether: value)
            self.rawTransaction = RawTransaction(value: wei, to: to, gasPrice: gasPrice, gasLimit: gasLimit, nonce: nonce)
        }
    }
    
    public func signTransaction(_ transaction: OstDevice.Transaction) throws -> String {
        guard let secureKey: OstSecureKey = try OstSecureKey.getSecKey(for: self.address!) else {
            throw OstError.actionFailed("Sign Transaction failed to perform")
        }
        
        let privateKey: String = String(data: secureKey.secData, encoding: .utf8)!
        let wallet: Wallet = Wallet(network: .mainnet, privateKey: privateKey, debugPrints: true)
        return try wallet.sign(rawTransaction: transaction.rawTransaction)
    }
}
