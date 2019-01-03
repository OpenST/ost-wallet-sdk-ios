//
//  OSTMultiSigOperationModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OSTMultiSigOperationModel: class {
    
    func get(_ id:  String) throws -> OSTMultiSigOperation?
    
    func getAll(_ ids:  Array<String>) -> [String: OSTMultiSigOperation?]
    
    func save(_ multiSigOperationData: [String : Any], success: ((OSTMultiSigOperation?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ multiSigOperationDataArray: Array<[String: Any]>, success: ((Array<OSTMultiSigOperation>?, Array<OSTMultiSigOperation>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
