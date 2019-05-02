//
//  OstFontConfig.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 25/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstFontProvider {
    var fontName:String = "Lato";
    var useSystemFont = true;
    
    init() {
        self.useSystemFont = true;
    }
    
    init(fontName:String) {
        self.fontName = fontName;
        self.useSystemFont = false;
    }
 
    func get(size:CGFloat) -> UIFont {
        if ( self.useSystemFont ) {
            return UIFont.systemFont(ofSize: size);
        }
        return UIFont(name: self.fontName, size: size)!;
    }
}

extension UIFont {
    public class func ostFont(size:CGFloat) -> UIFont {
        let provider = OstTheme.fontProvider;
        return provider.get(size: size);
    }
}



