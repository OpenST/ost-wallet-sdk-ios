//
//  TabBarViewController.swift
//  DemoApp
//
//  Created by aniket ayachit on 20/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

enum TabBarTagEnum: Int {
    case home,
    wallet,
    setting
}

class TabBarViewController: UITabBarController {
    
    var homeViewController: OstHomeViewController?
    var walletViewController: OstWalletViewController?
    var settingViewController: OptionsViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        self.selectedViewController = viewControllers![1]
    }
    
    func createViews() {
        let viewControllerList = createTabBarViewControllers()
        viewControllers = viewControllerList
    }
    
    func  createTabBarViewControllers() -> [UIViewController] {
        //HomeVC
        let homeVC = OstHomeViewController()
        homeVC.tabbarController = self
        let homeNavController = UINavigationController(rootViewController: homeVC)
        homeNavController.tabBarItem = UITabBarItem(title: "Home",
                                         image: UIImage(named: "userImage"),
                                         selectedImage: UIImage(named: "userImageSelected"))
        homeNavController.tabBarItem.tag = 1
        
        //Wallet VC
        let walletVC = OstWalletViewController()
        walletVC.tabbarController = self
        let walletNavController = UINavigationController(rootViewController: walletVC)
        walletNavController.tabBarItem = UITabBarItem(title: "Wallet",
                                                      image: UIImage(named: "walletImage"),
                                                      selectedImage: UIImage(named: "walletImageSelected"))
       walletNavController.tabBarItem.tag = 2
        
        //SettingsVC
        let settingVC = OptionsViewController()
        settingVC.tabbarController = self
        let settingsNavController = UINavigationController(rootViewController: settingVC)
        settingsNavController.tabBarItem = UITabBarItem(title: "Settings",
                                                        image: UIImage(named: "settingImage"),
                                                        selectedImage: UIImage(named: "settingImageSelected"))
        settingsNavController.tabBarItem.tag = 3
        
        return [homeNavController, walletNavController, settingsNavController]
    }
    
    //MARK: - Tab Bar Delegate
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

    }
    
    func hideTabBar() {
        var frame = self.tabBar.frame
        frame.origin.y = self.view.frame.size.height + frame.size.height
        UIView.animate(withDuration: 0.3, animations: {
            self.tabBar.frame = frame
        })
    }
    
    func showTabBar() {
        var frame = self.tabBar.frame
        frame.origin.y = self.view.frame.size.height - frame.size.height
        UIView.animate(withDuration: 0.3, animations: {
            self.tabBar.frame = frame
        })
    }
}
