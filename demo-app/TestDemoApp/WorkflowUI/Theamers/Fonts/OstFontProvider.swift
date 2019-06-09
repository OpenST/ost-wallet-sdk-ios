//
//  OstFontConfig.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 25/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstFontProvider {
    var fontName:String = "";
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
    
    func getBlack(size:CGFloat) -> UIFont {
        if ( self.useSystemFont ) {
            return UIFont.systemFont(ofSize: size).bold();
        }
        if let font = UIFont(name: "\(self.fontName)-Black", size: size) {
            return font
        }
        return UIFont.systemFont(ofSize: size).bold();
    }
}

extension UIFont {
    public class func ostFont(size:CGFloat) -> UIFont {
        let provider = OstTheme.fontProvider;
        return provider.get(size: size);
    }
}



