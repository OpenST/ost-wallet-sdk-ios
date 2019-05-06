//
//  OstUIKit.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 26/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

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
