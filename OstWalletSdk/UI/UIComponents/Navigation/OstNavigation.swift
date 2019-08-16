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
    
    //Font-Size
    var fontSize: CGFloat = 16;
    
    //Tint Color
    var barTintColor: UIColor
    
    //Back button tint color
    var backButtonTintColor: UIColor? = nil
    
    //Title Color
    var barTextColor: UIColor = .black
    
    //Translucent
    var isTranslucent: Bool = false
    
    //Back Indicator
    var backBarButtonImage: UIImage?
    
    //Logo
    let navLogo: UIImage
    
    //Logo Padding
    let navLogoHeightPadding: CGFloat = 20
    
    init() {
        self.navLogo = OstTheme.getInstance().getNavBarLogo()
        self.barTintColor = OstTheme.getInstance().getNavBarTintColor()
    }
    
    /// Apply style to navigation bar
    ///
    /// - Parameters:
    ///   - navController: UINavigationController
    ///   - target: Target for back button pressed.
    ///   - action: Action for back button pressed.
    func apply(_ navController: UINavigationController,
               target: AnyObject? = nil,
               action: Selector? = nil) {
        
        setBackBarButtonImage(navController: navController)
        
        navController.navigationBar.isTranslucent = isTranslucent
        navController.navigationBar.barTintColor = barTintColor
        navController.navigationBar.titleTextAttributes = [.foregroundColor: barTextColor,
                                                           .font: UIFont.systemFont(ofSize: fontSize)]
        
        if nil != backBarButtonImage && nil != target  &&  nil != action {
            navController.navigationBar.backIndicatorImage = backBarButtonImage
            navController.navigationBar.backIndicatorTransitionMaskImage = backBarButtonImage
            
            target!.navigationItem.leftBarButtonItems = getNavigationBarItems(image: backBarButtonImage!, target: target, action: action!)
        }
        
        let shadowImage = UIImage()
        navController.navigationBar.shadowImage = shadowImage
        
        let imageView = UIImageView(image: self.navLogo)
        let bannerWidth = navController.navigationBar.frame.size.width - (80*2)
        let bannerHeight = navController.navigationBar.frame.size.height - self.navLogoHeightPadding
        imageView.frame = CGRect(x: 0, y: 0, width: bannerWidth, height: bannerHeight)
        imageView.contentMode = .scaleAspectFit
        navController.viewControllers.last?.navigationItem.titleView = imageView
    }
    
    /// Set back button for navigation bar
    ///
    /// - Parameter navController: UINavigationController
    func setBackBarButtonImage(navController: UINavigationController) {
        let navViewControllers = navController.viewControllers
        let themeConfig = OstTheme.getInstance()
        if navViewControllers.last === navViewControllers.first {
            backBarButtonImage = themeConfig.getImageFromFramework(imageName: "ost_close")
            self.backButtonTintColor = themeConfig.getCloseTintColor()
        }else {
            backBarButtonImage = themeConfig.getImageFromFramework(imageName: "ost_back_arrow")
            self.backButtonTintColor = themeConfig.getBackTintColor()
        }
    }
    
    /// Get navigation bar items
    ///
    /// - Parameters:
    ///   - image: Image for bar item
    ///   - target: Target for bar item
    ///   - action: Action for bar item
    /// - Returns: Array for bar items
    func getNavigationBarItems(image: UIImage,
                               target: AnyObject?,
                               action: Selector) -> [UIBarButtonItem] {
        
        let negativeSpacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.fixedSpace, target: nil, action: nil)
        negativeSpacer.width = -8
        
        
        let backButton = UIBarButtonItem(image: backBarButtonImage, style: .plain, target: target, action: action)
        backButton.tintColor = backButtonTintColor
        
        return [negativeSpacer, backButton]
    }
}
