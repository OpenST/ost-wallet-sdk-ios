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
                    if let rootVC = (self.selectedViewController as? UINavigationController)?.viewControllers.first as? OptionsViewController {
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
        homeNavController.tabBarItem = UITabBarItem(title: "Users",
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
    
    func showAuthorizeDeviceOptions() {
        self.selectedViewController = viewControllers![2]
        if let rootVC = (self.selectedViewController as? UINavigationController)?.viewControllers.first as? OptionsViewController {
            rootVC.openAuthorizeDeviceViewIfRequired()
        }
    }
    
    //MARK: - Jump
    
    @objc func jumpToWalletVC(withWorkflowId workflowId: String? = nil) {
        self.selectedViewController = viewControllers![1]
        
        if let walletVC = getWalletVC(),
            nil != workflowId{
            walletVC.subscribeToWorkflowId(workflowId!)
        }
    }
    
    //MAKR: - VC
    func getUsersVC() -> OstHomeViewController?{
        let homeNavVC = viewControllers?[0] as? UINavigationController
        return homeNavVC?.viewControllers.first as? OstHomeViewController
    }
    
    func getWalletVC() -> OstWalletViewController? {
        let walletNavVC = viewControllers?[1] as? UINavigationController
        return walletNavVC?.viewControllers.first as? OstWalletViewController
    }
    
    func getOptionsVC() -> OptionsViewController? {
        let optionNavVC = viewControllers?[2] as? UINavigationController
        return optionNavVC?.viewControllers.first as? OptionsViewController
    }
    
}
