//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstContent: NSObject {
    private static var instance: OstContent? = nil
    var contentConfig: [String: Any] = [:]
    
    /// Get Instance for OstContent class
    ///
    /// - Returns: OstContent
    class func getInstance() -> OstContent {
        var instance = OstContent.instance
        if nil == instance {
            instance = OstContent(contentConfig: [:])
        }
        return instance!
    }
    
    /// Initialize
    ///
    /// - Parameter contentConfig: Config
    init(contentConfig: [String: Any]) {
        self.contentConfig = contentConfig
        super.init()
        OstContent.instance = self
    }
    
    /// Get url for terms and conditions
    ///
    /// - Returns: String
    func getTCURL() -> String {
        if let urlTC = contentConfig["terms_and_condition"] as? [String: Any],
            let url = urlTC["url"] as? String {
                return url
        }
        return (OstDefaultContent.content["terms_and_condition"] as! [String: Any])["url"] as! String
    }
}

@objc class OstDefaultContent: NSObject {
    static let content: [String: Any] = [
        "terms_and_condition": [
            "url": "https://drive.google.com/file/d/1QTZ7_EYpbo5Cr7sLdqkKbuwZu-tmZHzD/view"
        ]
    ]
}
