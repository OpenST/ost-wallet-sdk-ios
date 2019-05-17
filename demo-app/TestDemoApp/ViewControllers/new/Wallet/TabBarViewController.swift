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
    
    var workflowCallbacks: OstWorkflowCallbacks! {
        didSet {
            if let rootVC = (self.selectedViewController as? UINavigationController)?.viewControllers.first,
                (rootVC is OstWalletViewController){
                (rootVC as! OstWalletViewController).workflowCallbacks = workflowCallbacks
            }
        }
    }
    
    var homeViewController: OstHomeViewController?
    var walletViewController: OstWalletViewController?
    var settingViewController: OptionsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createViews()
        
        guard let currentDevice = CurrentUserModel.getInstance.currentDevice else {return}
        if currentDevice.isStatusRegistered {
            if let currentUser = CurrentUserModel.getInstance.ostUser {
                if currentUser.isStatusActivated {
                    self.selectedViewController = viewControllers![2]
                    if let rootVC = (self.selectedViewController as! UINavigationController).viewControllers.first as? OptionsViewController {
                        rootVC.openAuthorizeDeviceViewIfRequired()
                    }
                    return

                }
            }
        }
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
        if let destinationVC = self.viewControllers![item.tag-1] as? UINavigationController,
            let rootVC = destinationVC.viewControllers.first as? OptionsViewController{
            rootVC.openAuthorizeDeviceViewIfRequired()
        }
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
