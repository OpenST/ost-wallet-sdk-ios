//
//  OstBundle.swift
//  OstSdk
//
//  Created by aniket ayachit on 07/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

class OstBundle {
    
    enum PermissionKey: String {
        case NSFaceIDUsageDescription
    }
    
    /// Get content of files
    ///
    /// - Parameters:
    ///   - file: file name
    ///   - fileExtension: file extension
    /// - Returns: Content of file
    /// - Throws: OstError
    class func getContentOf(file: String, fileExtension: String) throws -> String {
        let ostBundle = OstBundle()
        let bundleObj = ostBundle.getSdkBundle()
        return try ostBundle.getFileContent(file,
                                            fileExtension: fileExtension,
                                            fromBundle: bundleObj)
    }
    
    /// Get application plist content
    ///
    /// - Parameters:
    ///   - key: Key name
    ///   - fileName: File name
    /// - Returns: Content for key
    /// - Throws: OstError
    class func getApplicationPlistContent(for key: String,
                                          fromFile fileName: String) throws -> AnyObject {
        
        let ostBundle = OstBundle()
        let bundleObj = ostBundle.getApplicatoinBundle()
        return try ostBundle.getPermissionDescription(for: key,
                                                      fromFile: fileName,
                                                      withExtension: "plist",
                                                      inBundle: bundleObj)
    }
    
    //MARK: Private Methods
    /// Initialize
    fileprivate init() { }
    
    /// Get Sdk bundle
    ///
    /// - Returns: Bundle
    fileprivate func getSdkBundle() -> Bundle {
        let bundle = Bundle(for: type(of: self))
        return bundle
    }
    
    /// Get Sdk bundle
    ///
    /// - Returns: Bundle
    fileprivate func getApplicatoinBundle() -> Bundle {
        let bundle = Bundle.main
        return bundle
    }
    
    /// Get file content
    ///
    /// - Parameters:
    ///   - fileName: File name
    ///   - fileExtension: Extension of file
    ///   - bundle: File exists in bundle name
    /// - Returns: Content of file
    /// - Throws: OstError
    fileprivate func getFileContent(_ fileName: String,
                                fileExtension: String,
                                fromBundle bundle: Bundle) throws -> String {
        
        if let filepath = bundle.path(forResource: fileName, ofType: fileExtension) {
            let contents = try String(contentsOfFile: filepath)
            return contents
        }
        throw OstError.init("u_b_gfc_1", "File not found: \(fileName)")
    }
    
    /// Get permission description
    ///
    /// - Parameters:
    ///   - key: Permission key
    ///   - fileName: File name
    ///   - extension: File extension
    ///   - bundle: Bundle
    /// - Returns: Description Text
    /// - Throws: OstError
    fileprivate func getPermissionDescription(for key: String,
                                              fromFile fileName: String,
                                              withExtension fileExtension: String,
                                              inBundle bundle: Bundle) throws -> AnyObject {
        
        let plistPath: String? = bundle.path(forResource: fileName, ofType: fileExtension)!
        let plistXML = FileManager.default.contents(atPath: plistPath!)!
        
        var propertyListForamt =  PropertyListSerialization.PropertyListFormat.xml //Format of the Property List.
        let plistData: [String: AnyObject] = try PropertyListSerialization
            .propertyList(from: plistXML,
                          options: .mutableContainersAndLeaves,
                          format: &propertyListForamt) as! [String : AnyObject]
        
        guard let description = plistData[key] else {
            throw OstError("u_b_gpd_1", OstErrorText.keyNotFound)
        }
        return description
    }
}
