//
//  OstMultiSigOperationModel.swift
//  OstSdk
//
//  Created by aniket ayachit on 03/01/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

public protocol OstMultiSigOperationModel: class {
    
    func get(_ id:  String) throws -> OstMultiSigOperation?
    
    func getAll(_ ids:  Array<String>) -> [String: OstMultiSigOperation?]
    
    func save(_ multiSigOperationData: [String : Any], success: ((OstMultiSigOperation?) -> Void)?, failure: ((Error) -> Void)?)
    
    func saveAll(_ multiSigOperationDataArray: Array<[String: Any]>, success: ((Array<OstMultiSigOperation>?, Array<OstMultiSigOperation>?) -> Void)?, failure: ((Error) -> Void)?)
    
    func delete(_ id: String, success: ((Bool)->Void)?)
    
    func deleteAll(_ ids: Array<String>, success: ((Bool) -> Void)?)
}
