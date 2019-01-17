//
//  OstMultiSigEntity.swift
//  OstSdk
//
//  Created by aniket ayachit on 10/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

public class OstMultiSig: OstBaseEntity {
    
    public func getDeviceMultiSigWallet() throws -> OstMultiSigWallet? {
        do {
            guard let multiSigWallets: [OstMultiSigWallet] = try OstMultiSigWalletRepository.sharedMultiSigWallet.getByParent(self.id) as? [OstMultiSigWallet] else {
                return nil
            }
            
            for multiSigWallet in multiSigWallets {
                guard let multiSigWalletAddress: String = multiSigWallet.address else {
                    continue
                }
                guard let _: OstSecureKey = try OstSecureKeyRepository.sharedSecureKey.get(multiSigWalletAddress) else {
                    continue
                }
                return multiSigWallet
            }
        }catch let error {
            throw error
        }
        
        return nil
    }
}

public extension OstMultiSig {
    var user_id : String? {
        return data["user_id"] as? String ?? nil
    }
    
    var address : String? {
        return data["address"] as? String ?? nil
    }
    
    var token_holder_id : String? {
        return data["token_holder_id"] as? String ?? nil
    }
    
    var wallets : Array<String>? {
        return data["wallets"] as? Array<String> ?? nil
    }
    
    var requirement: String? {
        return data["requirement"] as? String ?? nil
    }
    
    var authorize_session_callprefix: String? {
        return data["authorize_session_callprefix"] as? String ?? nil
    }
}
