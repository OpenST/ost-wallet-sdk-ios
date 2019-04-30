//
//  OstLabel.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 26/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstLabel:BaseTheamer {
    
    //Font-Size
    public var fontSize:CGFloat = 16;

    //Color
    public var textColor:UIColor = UIColor.black;
    
    func apply(_ label:UILabel) {
        label.font = getFontProvider().get(size: fontSize);
        label.textColor = textColor;
        label.numberOfLines = 0;
    }

}
