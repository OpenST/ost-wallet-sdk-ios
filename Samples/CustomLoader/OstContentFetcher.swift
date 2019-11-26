//
//  ContentFetcher.swift
//  Airport Locator
//
//  Created by aniket ayachit on 09/11/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation

@objc public class OstContentFetcher: NSObject {
  
  /// Get file content in string fromat. File should be available in Bundle.
  /// - Parameters:
  ///   - fileName: Name of the file
  ///   - ofType: Exetension of file
  /// - Returns:Content of file if file is present and contnet is retrievable, else it returns `nil`
  class func getFileContent(fileName: String,
                            ofType type: String) -> String? {
    
    let bundle = Bundle.main
    var contentString: String? = nil
    
    //Get file path
    if let filepath = bundle.path(forResource: fileName,
                                  ofType: type){
      
      //Fetch content of file
      contentString = try? String(contentsOfFile: filepath)
    }
    
    //Returns converted string z
    return contentString
  }
  
  /// Convert given string into JSON object
  /// - Parameter val: Value to be converted in to JSON object
  class func toJSONObject(_ val: String) throws -> Any {
    //Contert file content in .utf encoding
    let data = val.data(using: .utf8)!
    //Convert encoded data into JSON object
    return try JSONSerialization.jsonObject(with: data, options: [])
  }
  
  /// Gets mock respomse for airports
  @objc public 
  class func getOstSdkMessages() -> [String: Any]? {
    var finalResponse: [String: Any]? = nil
    
    if let fileContent = self.getFileContent(fileName: "OstSdkMessages",
                                             ofType: "json") {
      //Convert file content into JSON object
        finalResponse = try? self.toJSONObject(fileContent) as! [String: Any]
    }
    
    //Returns converted json object
    return finalResponse
  }
}
