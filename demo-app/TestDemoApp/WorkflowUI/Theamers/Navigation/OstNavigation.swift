//
//  OstNavigation.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 30/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import Foundation
import UIKit

class OstNavigation {
    //Font Provider
    public var fontProvider: OstFontProvider?;
    
    //Font-Size
    public var fontSize: CGFloat = 16;
    
    //Tint Color
    public var barTintColor: UIColor = UIColor.white
    
    //Title Color
    public var barTextColor: UIColor = .black
    
    //Translucent
    public var isTranslucent: Bool = false
    
    //Back Indicator
    public var backBarButtonImage: UIImage?
    
    init() { }
    
    func apply(_ navigation: UINavigationController, target: AnyObject? = nil, action: Selector? = nil) {
        navigation.navigationBar.isTranslucent = isTranslucent
        navigation.navigationBar.barTintColor = barTintColor
        navigation.navigationBar.titleTextAttributes = [.foregroundColor: barTextColor,
                                                        .font: getFontProvider().get(size: fontSize).bold()]
        if nil != backBarButtonImage && nil != target  &&  nil != action {
            navigation.navigationBar.backIndicatorImage = backBarButtonImage
            navigation.navigationBar.backIndicatorTransitionMaskImage = backBarButtonImage
            
            target!.navigationItem.leftBarButtonItems = createWithImage(image: backBarButtonImage!, target: target, action: action!)
        }
    }
    
    func getFontProvider() -> OstFontProvider {
        if ( nil != fontProvider) {
            return fontProvider!;
        }
        return OstTheme.fontProvider;
    }
    
    func createWithImage(image: UIImage, target: AnyObject?, action: Selector) -> [UIBarButtonItem] {
        // recommended maximum image height 22 points (i.e. 22 @1x, 44 @2x, 66 @3x)
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -8
        
        let backImageView = UIImageView(image: image)
        let customBarButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        backImageView.frame = CGRect(x: -8, y: 8, width: 30, height: 30)
        customBarButton.addSubview(backImageView)
        customBarButton.addTarget(target, action: action, for: .touchUpInside)
        
        return [negativeSpacer, UIBarButtonItem(customView: customBarButton)]
    }
}
