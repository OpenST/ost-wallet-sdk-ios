//
//  CPrimaryButton.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 25/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstPrimaryButtonTheamer {
    //Defaults
    
    init() {}
    
    public var titleColor:UIColor = UIColor.color(255, 255, 255);
    public var titleFontSize:CGFloat = 18;
    public var backgroundColor:UIColor = UIColor.color(228, 176, 48);
    public var fontProvider:OstFontProvider?;
    
    func getFontProvider() -> OstFontProvider {
        if ( nil != fontProvider) {
            return fontProvider!;
        }
        return OstTheme.fontProvider;
    }
    
    
    func apply(button:UIButton) {
        button.backgroundColor = self.backgroundColor;
        //Title Label.
        if ( nil != button.titleLabel ) {
            let titleLabel = button.titleLabel!;
            titleLabel.font = getFontProvider().get(size: titleFontSize);
            button.setTitleColor(titleColor, for: .normal);
            button.setTitleColor(titleColor, for: .highlighted);
            button.setTitleColor(titleColor, for: .focused);
            button.setTitleColor(titleColor, for: .selected);
        }
    
    }
}

extension UIButton {
    class func ostPrimaryButton() -> UIButton {
        let btn = UIButton();
        let themer = OstTheme.primaryButtonConfig;
        themer.apply(button: btn);
        return btn;
    }
}
