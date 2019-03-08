//
//  SolidityHandler.swift
//  OstSdk
//
//  Created by aniket ayachit on 22/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstSolidityHandler: SolidityFunctionHandler {
    var address: EthereumAddress?
    
    init() { }
    func call(_ call: EthereumCall, outputs: [SolidityFunctionParameter], block: EthereumQuantityTag, completion: @escaping ([String : Any]?, Error?) -> Void) {
        completion(nil, nil)
    }
    
    func send(_ transaction: EthereumTransaction, completion: @escaping (EthereumData?, Error?) -> Void) {
        completion(nil, nil)
    }
    
    func estimateGas(_ call: EthereumCall, completion: @escaping (EthereumQuantity?, Error?) -> Void) {
        completion(nil, nil)
    }
}
