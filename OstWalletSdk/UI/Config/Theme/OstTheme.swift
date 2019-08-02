//
/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

@objc class OstTheme: NSObject {
    private static var instance: OstTheme? = nil

    /// Get instance for OstTheme
    ///
    /// - Returns: OstTheme
    class func getInstance() -> OstTheme {
        var instance = OstTheme.instance
        if nil == instance {
            instance = OstTheme()
        }
        return instance!
    }
    
    let themeConfig: [String: Any]
    
    /// Initialize
    ///
    /// - Parameter themeConfig: Theme config
    init(themeConfig: [String: Any]? = nil) {
        let data = OstBundle.getContentOf(file: "OstThemeConfig", fileExtension: "json")
        var finalConfig = try! OstUtils.toJSONObject(data!) as! [String: Any]
        OstUtils.deepMerge(themeConfig ?? [:], into: &finalConfig)
        
        self.themeConfig = finalConfig
        
        super.init()
        OstTheme.instance = self
    }
    
    /// Get `h1` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH1Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h1"] as! [String : Any])
    }
    
    /// Get `h2` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH2Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h2"] as! [String: Any])
    }
    
    /// Get `h3` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH3Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h3"] as! [String: Any])
    }
    
    /// Get `h4` theme config
    ///
    /// - Returns: OstLabelConfig
    func getH4Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["h4"] as! [String: Any])
    }
    
    /// Get `c1` theme config
    ///
    /// - Returns: OstLabelConfig
    func getC1Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["c1"] as! [String: Any])
    }
    
    /// Get `c2` theme config
    ///
    /// - Returns: OstLabelConfig
    func getC2Config() -> OstLabelConfig {
        return OstLabelConfig(config: themeConfig["c2"] as! [String: Any])
    }
    
    /// Get `b1` theme config
    ///
    /// - Returns: OstButtonConfig
    func getB1Config() -> OstButtonConfig {
        return  OstButtonConfig(config: themeConfig["b1"] as! [String: Any])
    }
    
    /// Get `b2` theme config
    ///
    /// - Returns: OstButtonConfig
    func getB2Config() -> OstButtonConfig {
        return  OstButtonConfig(config: themeConfig["b2"] as! [String: Any])
    }
    
    /// Get `b3` theme config
    ///
    /// - Returns: OstButtonConfig
    func getB3Config() -> OstButtonConfig {
        return  OstButtonConfig(config: themeConfig["b3"] as! [String: Any])
    }
    
    /// Get navigation bar logo
    ///
    /// - Returns: Image
    func getNavBarLogo() -> UIImage {
        let navLogoDict = themeConfig["nav_bar_logo_image"] as! [String: Any]
        let imageName = navLogoDict["asset_name"] as! String

        return UIImage(named: imageName) ?? getImageFromFramework(imageName: imageName)
    }
    
    func getNavBarTintColor() -> UIColor {
        
        let navConfig = themeConfig["navigation_bar"] as! [String: Any]
        let tintColor = navConfig["tint_color"] as! String
        return UIColor.color(hex: tintColor)
    }
    
    /// Get back button tint color
    ///
    /// - Returns: Color
    func getBackTintColor() -> UIColor {
        let navConfig = themeConfig["icons"] as! [String: Any]
        let backIcon = navConfig["back"] as! [String: Any]
        let tintColor = backIcon["tint_color"] as! String
        return UIColor.color(hex: tintColor)
    }
    
    /// Get close button tint color
    ///
    /// - Returns: Color
    func getCloseTintColor() -> UIColor {
        let navConfig = themeConfig["icons"] as! [String: Any]
        let backIcon = navConfig["close"] as! [String: Any]
        let tintColor = backIcon["tint_color"] as! String
        return UIColor.color(hex: tintColor)
    }
    
    /// get image from framework
    ///
    /// - Parameter imageName: Image name
    /// - Returns: Image
    func getImageFromFramework(imageName: String) -> UIImage {
        return UIImage(named: imageName, in: Bundle(for: type(of: self)), compatibleWith: nil)!
    }
}
