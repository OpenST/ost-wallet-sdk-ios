//
//  OstBundle.swift
//  OstSdk
//
//  Created by aniket ayachit on 07/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstBundle {
    
    class func getContentOf(file: String, fileExtension: String) throws -> String {
        let ostBundle = OstBundle()
        return try ostBundle.getFileContent(file, fileExtension: fileExtension)
    }
    
    private init() { }
    
    private func getBundle() -> Bundle {
        let bundle = Bundle(for: type(of: self))
        return bundle
    }
    
    private func getFileContent(_ fileName: String, fileExtension: String) throws -> String {
        let bundle = getBundle()
        if let filepath = bundle.path(forResource: fileName, ofType: fileExtension) {
            let contents = try String(contentsOfFile: filepath)
            return contents
        }
        throw OstError.init("", "File not found: \(fileName)")
    }
}
