/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class AppConfig: NSObject {
    static let appThemeConfig: [String: Any] = [
        "h1": ["size": 20,
               "font": "SFProDisplay-Semibold",
               "color": "#438bad"],
        
        "h2": ["size": 17,
               "font": "SFProDisplay-Medium",
               "color": "#666666"],
        
        "h3": ["size": 15,
               "font": "SFProDisplay-Regular",
               "color": "#888888"],
        
        "h4": ["size": 12,
               "font": "SFProDisplay-Regular",
               "color": "#888888"],
        
        "primary_button": ["background_color": ""],
        "secondary_button": ["background_color": ""]
    ]
    
    static let appContentConfig: [String: Any] = [
        "image_nav_bar_logo": [
            "name": "ostLogoBlue",
            "url": ""
        ],
        "url_terms_and_condition": [
            "url": "https://drive.google.com/file/d/1QTZ7_EYpbo5Cr7sLdqkKbuwZu-tmZHzD/view"
        ]
    ]
}
