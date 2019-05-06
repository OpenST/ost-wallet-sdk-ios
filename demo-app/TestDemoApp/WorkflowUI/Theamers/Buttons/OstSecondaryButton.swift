//
//  OstSecondaryButton.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 25/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstSecondaryButton: OstButtonTheamer {
    init() {
        //Title Font-Size
        let titleFontSize = CGFloat(18);
        super.init(titleFontSize: titleFontSize);
        
        //Title Colors
        setTitleColor(color: UIColor.color(22, 141, 193), state: .normal);
        setTitleColor(color: UIColor.white, state: .highlighted);
        
        //Title Edge Inset
        self.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14);
        
        //Background Images
        let activeBgImg = UIImage.withColor(color: UIColor.white);
        setBackgroundImage(image: activeBgImg, state: .normal);
        
        let highlightedBgImg = UIImage.withColor(22, 141, 193);
        setBackgroundImage(image: highlightedBgImg, state: .highlighted);

//        let disabledImg = UIImage.withColor(154, 204, 215, 0.3);
//        setBackgroundImage(image: disabledImg, state: .disabled);
        
        //Corner Radius
        self.cornerRadius = 10;
        self.borderColor = UIColor.color(22, 141, 193).cgColor;
        self.borderWidth = 2;
    }
}
