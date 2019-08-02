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
        var finalConfig = OstDefaultTheme.theme
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


@objc class OstDefaultTheme: NSObject {
    static let theme: [String: Any] = [
        
        "nav_bar_logo_image": [
            "asset_name": "ost_nav_bar_logo"
        ],
        
        "h1": ["size": 20,
               "color": "#438bad",
               "font_weight": "semi_bold",
               "alignment": "center"
        ],
        
        "h2": ["size": 17,
               "color": "#666666",
               "font_weight": "medium",
                "alignment": "center"
        ],
        
        "h3": ["size": 15,
               "color": "#888888",
               "font_weight": "regular",
               "alignment": "center"
        ],
        
        "h4": ["size": 12,
               "color": "#888888",
               "font_weight": "regular",
               "alignment": "center"
        ],
        
        "c1": ["size": 14,
               "color": "#484848",
               "font_weight": "bold",
               "alignment": "left"
        ],
        
        "c2": ["size": 12,
               "color": "#6F6F6F",
               "font_weight": "regular",
               "alignment": "left"
        ],
        
        "b1": [
            "size": 17,
            "color": "#ffffff",
            "background_color": "#438bad",
            "font_weight": "medium"
        ],
        
        "b2": [
            "size": 17,
            "color": "#438bad",
            "background_color": "#f8f8f8",
            "font_weight": "semi_bold"
        ],
        
        "b3": [
            "size": 12,
            "color": "#ffffff",
            "background_color": "#438bad",
            "font_weight": "medium"
        ],
        
        "b4": [
            "size": 12,
            "color": "#438bad",
            "background_color": "#ffffff",
            "font_weight": "medium"
        ],
        
        "navigation_bar": [
            "tint_color": "#ffffff"
        ],
        
        "icons": [
            "close": [
                "tint_color": "#438bad"
            ],
            "back":[
                "tint_color": "#438bad"
            ]
        ]
    ]
}
