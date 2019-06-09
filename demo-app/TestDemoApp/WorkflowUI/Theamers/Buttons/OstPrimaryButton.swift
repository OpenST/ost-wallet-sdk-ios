//
//  CPrimaryButton.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 25/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstPrimaryButton : OstButtonTheamer {
    init() {
        //Title Font-Size
        super.init(titleFontSize: CGFloat(18));
        
        //Title Colors
        setTitleColor(color: UIColor.white, state: .normal);
        setTitleColor(color: UIColor.white, state: .disabled);
        
        //Title Edge Inset
        self.contentEdgeInsets = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14);
        
        //Background Images
        
        
        let activeBgImg = UIImage.withColor(22, 141, 193);
        setBackgroundImage(image: activeBgImg, state: .normal);
        
        let highlightedBgImg = UIImage.withColor(128, 180, 191);
        setBackgroundImage(image: highlightedBgImg, state: .highlighted);
        
//        let disabledImg = UIImage.withColor(154, 204, 215, 0.3);
//        setBackgroundImage(image: disabledImg, state: .disabled);
        
        //Corner Radius
        self.cornerRadius = 10;
    }
}
