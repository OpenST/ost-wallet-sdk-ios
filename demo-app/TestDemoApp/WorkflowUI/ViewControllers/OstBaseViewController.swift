//
//  BaseAppViewController.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstBaseViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    public var navigationThemer: OstNavigation =  OstTheme.blueNavigation
    
    var shouldFireIsMovingFromParent = false;
    deinit {
        print("deinit: \(String(describing: self))")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self

        // Do any additional setup after loading the view.

        //Configure ViewController as needed.
        configure();
        
        //Style Parent view as needed.
        styleViewControllerView();
        
        //Style Navigation Controller.
        
        //Add all sub-views.
        addSubviews();
        
        //Add Layout Constraints.
        addLayoutConstraints();
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear( animated );
        self.resignFirstResponder();
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        
        if ( self.shouldFireIsMovingFromParent) {
            if ( (self.isMovingFromParent || self.isBeingDismissed)
                || (nil != self.navigationController && self.navigationController!.isBeingDismissed )
                || (nil != self.navigationController && self.navigationController!.isMovingFromParent )
                ) {
                //Trigger a notification.
                NotificationCenter.default.post(name: .ostVCIsMovingFromParent, object: self);
            }
        }
    }
    
    func configure() {
        //This method can be over-ridden by derived class to change default configurations.
    }
    
    func styleViewControllerView() {
        self.view.backgroundColor = .white;
    }
    
    func getNavBarTitle() -> String {
        return ""
    }
    
    func setupNavigationBar() {
        if nil == self.navigationController {
            return;
        }
        self.navigationItem.title = getNavBarTitle()
        
        navigationThemer.apply(self.navigationController!,
                               target: getTargetForNavBarBackbutton(),
                               action: getSelectorForNavBarBackbutton())
    }
    
    func getTargetForNavBarBackbutton() -> AnyObject? {
        weak var weakSelf = self
        return weakSelf
    }
    
    func getSelectorForNavBarBackbutton() -> Selector? {
        weak var weakSelf = self
        return #selector(weakSelf!.tappedBackButton)
    }
    
    @objc func tappedBackButton() {
        self.removeViewController();
    }
    
    func removeViewController(animated flag: Bool = true, completion: (() -> Void)? = nil) {
        if ( nil != self.navigationController && self.navigationController!.viewControllers.first! != self ) {
            let selfIndex = self.navigationController?.viewControllers.firstIndex(of: self)
            if nil == selfIndex {
                return
            }
            let beforeVC = self.navigationController?.viewControllers[selfIndex!-1]
            self.navigationController?.popToViewController(beforeVC!, animated: flag)
        }
        else if ( nil != self.presentingViewController) {
            self.dismiss(animated: flag, completion: completion);
        }
    }
    
    func addSubviews() {
        setupNavigationBar()
        // Add subviews. Make sure to call super method (applicable to most cases).
        // super.addSubviews();
    }
    
    func addLayoutConstraints() {
        // Add Layout Constraints. Make sure to call super method (applicable to most cases).
        // super.addLayoutConstraints();
    }

    // Helper method to add subview to UIViewController main view.
    func addSubview( _ view: UIView ) {
        self.view.addSubview( view );
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func showDeviceIsAuthroizingAlert() {
        
    }
}


public extension Notification.Name {
    static let ostVCIsMovingFromParent = Notification.Name("isMovingFromParent");
}

public extension UIViewController {
    func presentViewControllerWithNavigationController(_ presneter: UIViewController, animated:Bool = true, completion: (() -> Void)? = nil ){
        var viewControllerToBePresented:UIViewController = self;
        viewControllerToBePresented = UINavigationController(rootViewController: self);
        presneter.present(viewControllerToBePresented, animated: animated, completion: completion);
    }
    
    func pushViewControllerOn(_ pusher: UIViewController, animated:Bool = true) {
        var navViewController:UINavigationController?;
        if ( pusher is UINavigationController ) {
            navViewController = (pusher as! UINavigationController);
        } else {
            navViewController = pusher.navigationController;
        }
        navViewController?.interactivePopGestureRecognizer?.isEnabled = false
        navViewController?.pushViewController(self, animated: animated);
    }
}
