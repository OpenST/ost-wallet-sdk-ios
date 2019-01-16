//
//  OstSecureStoreModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 08/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

protocol OstSecureKeyModel: class {
    func get(_ id: String) throws -> OstSecureKey?
    
    func save(_ secureKeyData: [String : Any], success: ((OstSecureKey?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
}
