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
    
    /// Get navigation bar logo
    ///
    /// - Returns: Image
    func getNavBarLogo() -> UIImage {
        if let navLogoDict = contentConfig["image_nav_bar_logo"] as? [String: Any],
            let imageName = navLogoDict["name"] as? String {

            return UIImage(named: imageName)!
        }
        
        let imageName = (OstDefaultContent.content["image_nav_bar_logo"] as! [String: Any])["name"] as! String
        
        return getImageFromFramework(imageName: imageName)
    }
    
    /// get image from framework
    ///
    /// - Parameter imageName: Image name
    /// - Returns: Image
    func getImageFromFramework(imageName: String) -> UIImage {
        return UIImage(named: imageName, in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }
    
    /// Get url for terms and conditions
    ///
    /// - Returns: <#return value description#>
    func getTCURL() -> String {
        if let urlTC = contentConfig["url_terms_and_condition"] as? [String: Any],
            let url = urlTC["url"] as? String {
                return url
        }
        
        return (OstDefaultContent.content["url_terms_and_condition"] as! [String: Any])["url"] as! String
    }
}

@objc class OstDefaultContent: NSObject {
    static let content: [String: Any] = [
        "image_nav_bar_logo": [
            "name": "ost_nav_bar_logo",
            "url": ""
        ],
        "url_terms_and_condition": [
            "url": "https://drive.google.com/file/d/1QTZ7_EYpbo5Cr7sLdqkKbuwZu-tmZHzD/view",
            "name": "Your PIN will be used to authorise sessions, transactions, redemptions and recover wallet. <tc>",
            "tc": ["name":"T&C Apply",
                   "url": "https://drive.google.com/file/d/1QTZ7_EYpbo5Cr7sLdqkKbuwZu-tmZHzD/view"]
        ],
    ]
}
