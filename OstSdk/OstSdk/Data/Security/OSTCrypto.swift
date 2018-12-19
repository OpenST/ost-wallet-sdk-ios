//
//  OSTSecure.swift
//  OstSdk
//
//  Created by aniket ayachit on 17/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

protocol OSTCrypto {
    
    func genSCryptKey(salt: Data, stringToCalculate: String) throws -> Data
    
    func genHKDFKey(salt saltBytes: [UInt8], data dataBytes: [UInt8]) throws -> [UInt8]
    
    func genDigest(bytes: [UInt8]) -> [UInt8]
}
