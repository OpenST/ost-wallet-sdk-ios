/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstB2Button: OstBaseButton {
    
    /// Set theme config for button
    override func setThemeConfig() {
        self.buttonConfig = OstTheme.getInstance().getB2Config()
        
        let activeBgImg = UIImage.withColor(color: buttonConfig!.getBackgroundColor());
        setBackgroundImage(image: activeBgImg, state: .normal);
    
        self.cEdgeInsets = UIEdgeInsets(top: 15, left: 14, bottom: 15, right: 14);
        self.cornerRadius = 5
        
        super.setThemeConfig()
    }
}
