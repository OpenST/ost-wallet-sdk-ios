//
//  OstLabel.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 26/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstLabelTheamer:BaseTheamer {
    
    //Font-Size
    public var fontSize:CGFloat = 16;

    //Color
    public var textColor:UIColor = UIColor.black;
    
    public var textAliginment: NSTextAlignment = .left
    
    //NSMutableParagraphStyle
    public var paragraphStyle:NSMutableParagraphStyle = NSMutableParagraphStyle();
    
    override init() {}
    
    func apply(_ label:UILabel) {
        label.font = getFontProvider().get(size: fontSize);
        label.textColor = textColor;
        label.numberOfLines = 0;
        label.textAlignment = textAliginment
    }
    
    func setText(_ label:UILabel, text: String?) {
        var textToSet = "";
        if (nil != text) {
            textToSet = text!;
        }
    
        let attrString = NSMutableAttributedString(string: textToSet);
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                value: paragraphStyle,
                                range: NSMakeRange(0, attrString.length));
        
        attrString.addAttribute(NSAttributedString.Key.font,
                                value: getFontProvider().get(size: fontSize),
                                range: NSMakeRange(0, attrString.length));
        
        label.attributedText = attrString;
        label.textAlignment = textAliginment
    }

}
