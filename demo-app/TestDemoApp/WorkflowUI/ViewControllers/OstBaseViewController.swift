//
//  BaseAppViewController.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class OstBaseViewController: UIViewController {

    var showNavigationController:Bool = true;
    var navigationThemer: OstNavigation =  OstTheme.blueNavigation
    
    deinit {
        print("deinit: \(String(describing: self))")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

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
                self.navigationItem.title = getNavBarTitle()
                if nil != self.navigationController {
                    weak var weakSelf = self
                    navigationThemer.apply(self.navigationController!, target: weakSelf, action: #selector(weakSelf!.tappedBackButton))
                }
            }
    
    @objc func tappedBackButton() {
        self.navigationController?.popViewController(animated: true)
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
    
    
    public func presentWith(_ presneter: UIViewController, animated:Bool = true, completion: (() -> Void)? = nil ){
        var viewControllerToBePresented:UIViewController = self;
        if ( showNavigationController ) {
            viewControllerToBePresented = UINavigationController(rootViewController: self);
        }
        presneter.present(viewControllerToBePresented, animated: animated, completion: completion);
    }
    
    public func pushWith(_ pusher: UIViewController, animated:Bool = true) {
        var navViewController:UINavigationController?;
        if ( pusher is UINavigationController ) {
            navViewController = (pusher as! UINavigationController);
        } else {
            navViewController = pusher.navigationController;
        }
        
        navViewController?.pushViewController(self, animated: animated);
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
