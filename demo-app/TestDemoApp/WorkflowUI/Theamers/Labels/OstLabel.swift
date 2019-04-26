//
//  OstLabel.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 26/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstLabel {
    //Font-Provider
    public var fontProvider:OstFontProvider?;
    
    //Font-Size
    public var fontSize:CGFloat = 16;

    //Color
    public var textColor:UIColor = UIColor.black;
    
    init() {}
    
    func apply(_ label:UILabel) {
        label.font = getFontProvider().get(size: fontSize);
        label.textColor = textColor;
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0;
    }
    
    func getFontProvider() -> OstFontProvider {
        if ( nil != fontProvider) {
            return fontProvider!;
        }
        return OstTheme.fontProvider;
    }

}
