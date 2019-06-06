/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
*/

import UIKit
import MaterialComponents.MDCTextField

class OstUIKit {
    class func primaryButton() -> OstButton {
        let view = OstButton();
        view.translatesAutoresizingMaskIntoConstraints = false
        let themer = OstTheme.primaryButton;
        view.setTheamer(themer);
        themer.apply(view);
        return view;
    }
    
    class func secondaryButton() -> OstButton {
        let view = OstButton();
        view.translatesAutoresizingMaskIntoConstraints = false
        let themer = OstTheme.secondaryButton;
        view.setTheamer(themer);
        themer.apply(view);
        return view;
    }
    
    class func linkButton() -> OstButton {
        let view = OstButton();
        view.translatesAutoresizingMaskIntoConstraints = false
        let themer = OstTheme.linkButton;
        view.setTheamer(themer);
        themer.apply(view);
        view.setTitleColor(UIColor.color(22, 141, 193), for: .normal)
        return view;
    }
    
    class func h1() -> OstLabel {
        let view = OstLabel();
        view.translatesAutoresizingMaskIntoConstraints = false
        let themer = OstTheme.h1;
        view.setTheamer(themer);
        themer.apply(view);
        return view;
    }
    
    class func leadLabel() -> OstLabel {
        let view = OstLabel();
        view.translatesAutoresizingMaskIntoConstraints = false
        let themer = OstTheme.leadLabel;
        view.setTheamer(themer);
        themer.apply(view);
        return view;
    }
    
    class func textField() -> MDCTextField {
        let view = MDCTextField();
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }
}
