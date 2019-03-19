/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

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
