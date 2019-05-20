//
//  IntroViewController.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class IntroViewController: OstBaseViewController, OstFlowInterruptedDelegate, OstRequestAcknowledgedDelegate, OstFlowCompleteDelegate {

    //MARK: - Variables
    var progressIndicator: OstProgressIndicator? = nil
    var fetchUser: Bool = false
    var isUserFetched: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if nil != CurrentEconomy.getInstance.tokenId && fetchUser && !isUserFetched {
            getUserFromServer()
            isUserFetched = true
        }
    }
    
    // MARK - Subviews
    let logoImageView: UIImageView = {
        let view = UIImageView(image: UIImage.init(named: "ostLogoBlue") );
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    let leadLabel: UILabel = {
        let view = OstUIKit.leadLabel();
        view.text = "Test your Brand Token Economy deployed on OST Platform";
        view.backgroundColor = .white;
        return view;
    }()
    
    let introImageView: UIImageView = {
        let view = UIImageView(image: UIImage.init(named: "ostIntroImage") );
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    var createAccountBtn: UIButton = {
        let view = OstUIKit.primaryButton();
        view.setTitle("Create Account", for: .normal);
        return view;
    }()

    var loginBtn: UIButton = {
        let view = OstUIKit.secondaryButton();
        view.setTitle("Log in", for: .normal);
        return view;
    }()
    
    override func addSubviews() {
        super.addSubviews();
        
        addButtonActions()
        
        addSubview(logoImageView);
        addSubview(leadLabel);
        addSubview(introImageView);
        addSubview(createAccountBtn);
        addSubview(loginBtn);
    }
    
    func addButtonActions() {
        weak var weakSelf = self
        createAccountBtn.addTarget(weakSelf, action: #selector(weakSelf!.createAccountButtonTapped(_:)), for: .touchUpInside)
        loginBtn.addTarget(weakSelf, action: #selector(weakSelf!.loginButtonTapped(_:)), for: .touchUpInside)
    }

    override func addLayoutConstraints() {
        super.addLayoutConstraints();
        
        logoImageView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        logoImageView.centerXAlignWithParent();
        logoImageView.setAspectRatio(width: 70, height: 38);
        
        leadLabel.placeBelow(toItem: logoImageView);
        leadLabel.applyBlockElementConstraints();
        
        introImageView.placeBelow(toItem: leadLabel, constant: 40);
        introImageView.setW375Width(width: 221)
        introImageView.setH667Height(height: 236)
        introImageView.centerXAlignWithParent();
        
        createAccountBtn.applyBlockElementConstraints();
        createAccountBtn.bottomFromTopAlign(toItem: loginBtn, constant: -20)
        
        loginBtn.placeBelow(toItem: createAccountBtn);
        loginBtn.applyBlockElementConstraints();
        loginBtn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true

    }
    
    //MARK: - Actions
    
    @objc func createAccountButtonTapped(_ sender: Any?) {
        let createAccountVC = SetupUserViewController()
        createAccountVC.viewControllerType = .signup
        createAccountVC.pushViewControllerOn(self)
    }
    
    @objc func loginButtonTapped(_ sender: Any?) {        
        let loginVC = SetupUserViewController()
        loginVC.viewControllerType = .login
        loginVC.pushViewControllerOn(self)
    }

    
    func getUserFromServer() {
        progressIndicator = OstProgressIndicator(progressText: "Fetching user...")
        getApplicationWindow()?.addSubview(progressIndicator!)
        progressIndicator?.show()

        try! OstWalletSdk.initialize(apiEndPoint: CurrentEconomy.getInstance.saasApiEndpoint!)

        CurrentUserModel.getInstance.getCurrentUser(onSuccess: {[weak self] (ostUser, ostDevice) in
            if ostUser.isStatusCreated {
                self?.activateUser()
            }else {
                self?.onLoginSuccess()
            }
        }) {[weak self] (failureResponse) in
            self?.onFailure(response: failureResponse)
        }
    }
    
    func activateUser() {
        removeProgressIndicator()
        let currentUse = CurrentUserModel.getInstance
        let workflowCallback = OstSdkInteract.getInstance.activateUser(userId: currentUse.ostUserId!,
                                                                   passphrasePrefixDelegate: currentUse,
                                                                   presenter: self)
        OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowCallback.workflowId,
                                             listner: self)
    }
    
    func onLoginSuccess() {
        let currentUser = CurrentUserModel.getInstance
        
        if currentUser.status!.caseInsensitiveCompare("created") == .orderedSame {
            
            if currentUser.ostUserStatus!.caseInsensitiveCompare("activated") == .orderedSame {
                UserAPI.notifyUserActivated()
                removeProgressIndicator()
                pushToTabBarController()
            }
            else if currentUser.ostUserStatus!.caseInsensitiveCompare("created") == .orderedSame {
                activateUser()
            }
        }else {
            removeProgressIndicator()
            pushToTabBarController()
        }
    }
    
    func removeProgressIndicator() {
        progressIndicator?.hide(onCompletion: {[weak self] (isCompleted) in
            self?.progressIndicator = nil
        })
    }
    
    func pushToTabBarController() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showTabbarController()
    }

    
    func onFailure(response:[String: Any]?) {
        removeProgressIndicator()
    }
    
    //MARK: - OstSdkInteract Delegate
    
    func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        
    }
    
    func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if let currentUser = CurrentUserModel.getInstance.ostUser {
            if currentUser.isStatusActivating {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
                    self?.pushToTabBarController()
                }
            }
        }
    }
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
    }
}
