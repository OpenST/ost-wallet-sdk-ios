/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import CryptoSwift

extension Data{
    func toDictionary() -> Dictionary<String, Any> {
        return NSKeyedUnarchiver.unarchiveObject(with: self) as! Dictionary<String, Any>
    }
    
    var soliditySHA3Hash: String {
        return sha3(SHA3.Variant.keccak256).toHexString()
        
    }
}
