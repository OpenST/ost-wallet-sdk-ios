//
//  OstSdkSecureStore.swift
//  OstSdk
//
//  Created by aniket ayachit on 14/12/18.
//  Copyright © 2018 aniket ayachit. All rights reserved.
//

import Foundation

protocol OSTSecureStore{
    
    func encrypt(data: Data) throws -> Data?
    
    func decrypt(data: Data) throws -> Data?
}
