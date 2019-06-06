/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation
import UIKit

class OstLinkButton: OstButtonTheamer {
    init() {
        //Title Font-Size
        let titleFontSize = CGFloat(17);
        super.init(titleFontSize: titleFontSize);
        
        //Title Colors
        setTitleColor(color: UIColor.color(22, 141, 193), state: .normal);
        setTitleColor(color: UIColor.color(22, 141, 193), state: .highlighted);
        setTitleColor(color: UIColor.color(22, 141, 193), state: .disabled);

        //Title Edge Inset
        self.contentEdgeInsets = UIEdgeInsets(top: 4 , left: 4, bottom: 4, right: 4);
        
        //Background Images
        let activeBgImg = UIImage.withColor(color: UIColor.white);
        setBackgroundImage(image: activeBgImg, state: .normal);
        
        let highlightedBgImg = UIImage.withColor(255, 255, 255, 0.0);
        setBackgroundImage(image: highlightedBgImg, state: .highlighted);
        
        //        let disabledImg = UIImage.withColor(154, 204, 215, 0.3);
        //        setBackgroundImage(image: disabledImg, state: .disabled);
        
        //Corner Radius
        self.cornerRadius = 10;
        self.borderColor = UIColor.white.cgColor;
        self.borderWidth = 2;
    }
    
    override func apply(_ view: UIButton) {
        super.apply(view)
        
        view.titleLabel!.font = getFontProvider().get(size: titleFontSize).bold()
    }
}
