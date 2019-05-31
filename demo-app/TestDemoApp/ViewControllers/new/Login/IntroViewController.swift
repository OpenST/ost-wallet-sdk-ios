//
//  IntroViewController.swift
//  TestDemoApp
//
//  Created by Rachin Kapoor on 29/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class IntroViewController: OstBaseViewController, OstFlowInterruptedDelegate, OstRequestAcknowledgedDelegate, OstFlowCompleteDelegate, CanConfigureEconomyProtocol {

    

    //MARK: - Variables
    var progressIndicator: OstProgressIndicator? = nil
    var fetchUser: Bool = false
    var isUserFetched: Bool = false
    var hasPerformedNormalFlow:Bool = false;
    var appUrlData:AppUrlData? {
        let delegate = UIApplication.shared.delegate as! AppDelegate;
        return delegate.getWebPageUrl();
    };
    
    var hasAppLink:Bool {
        let delegate = UIApplication.shared.delegate as! AppDelegate;
        return delegate.hasWebLink();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
        if ( !hasAppLink ) {
            normalFlow();
        }
    }
    
    
    //MARK: - CanConfigureEconomyProtocol methods.
    func defaultEconomySet(payload: [String : Any?]) {
        // This method is called when following condition(s) are true:
        // nil == CurrentEconomy.getInstance.economyDetails
        // This viewController is the last view controller in navigation chain.
        // Note: CurrentEconomy.getInstance.economyDetails has been updated by this time.
        
        // Let's go to sign-up page silently.
        self.openSetupUserVC();
        
        // Update hasPerformedNormalFlow flag so that when user presses back, we skip the normalFlow.
        hasPerformedNormalFlow = true;
    }
    
    func newEconomySet(payload: [String : Any?]) {
        //Go-to Signup/Login.
        openSetupUserVC();
    }
    
    func newEconomyNotSet() {
        //Perform normal checks and proceed.
        normalFlow();
    }
    
    func sameEconomySet() {
        //Perform normal checks and proceed.
        normalFlow();
    }
    
    func clearAppUrlData() {
        let delegate = UIApplication.shared.delegate as! AppDelegate;
        delegate.clearWebPageUrl();
    }
    
    func showLogoutAlert() {
        
    }
    
    func appUrlDataAvailable() {
        //Get the last view controller.
        let vc:UIViewController = self.navigationController!.viewControllers.last!;
        
        //Ensure appUrlData is not nil.
        if ( nil == appUrlData ) {
            if ( vc == self ) {
                //Controle should never come here.
                normalFlow();
            }
            return;
        }
        
        //Ensure payload is valid.
        let economyParamsJson:String? = appUrlData!.params["ld"] as? String;
        let economyPayload = CurrentEconomy.getQRJsonData(economyParamsJson ?? "{}");
        if ( appUrlData!.action == .unknown || nil == economyPayload  ) {
            //Show invalid url alert.
            //Note: Also update message in TabBarViewController if needed.
            let alert = UIAlertController(title: "Invalid Url", message: "The url link is invalid.", preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));
            vc.present( alert, animated: true, completion: nil);

            if ( vc == self ) {
                //Continue normalFlow.
                normalFlow();
            }
            return;
        } else if ( appUrlData!.action != .launch ) {
            //We can't handle this action.
            if ( vc == self ) {
                //Continue normalFlow.
                normalFlow();
            }
            return;
        }
        
        //Ensure user has a pre-configured economy.
        if ( nil == CurrentEconomy.getInstance.economyDetails ) {
            //No pre-configured economy found.
            //Set the economy details.
            CurrentEconomy.getInstance.economyDetails = economyPayload! as [String : Any];
            
            //As current economy is null, user is either on intro page OR on sign-up/login page.
            if let canConfigureVc = vc as? CanConfigureEconomyProtocol {
                canConfigureVc.defaultEconomySet(payload: economyPayload!);
                return;
            }
            //The controle should not reach here.
            //But if it does, make sure to call normalFlow.
            if ( vc == self ) {
                normalFlow();
            }
            return;
        }
        
        //Ensure user has a different economy configured.
        //-- small g stands for 'given'
        let gMappyEndPoint:String = economyPayload!["mappy_api_endpoint"] as! String;
        let gSaasApiEndpoint:String = economyPayload!["saas_api_endpoint"] as! String;
        let gTokenId:String = ConversionHelper.toString( economyPayload!["token_id"]! )!;
        let gUrlId:String = economyPayload!["url_id"] as! String;
        let gTokenName: String = economyPayload!["token_name"] as! String;
        
        //-- small k stands for 'known'.
        let kEconomy = CurrentEconomy.getInstance;
        if (( gMappyEndPoint == kEconomy.mappyApiEndpoint )
            && ( gSaasApiEndpoint == kEconomy.saasApiEndpoint)
            && ( gTokenId == kEconomy.tokenId)
            && ( gUrlId == kEconomy.urlId))
        {
            //User has the same economy configured as the payload.
            let vc:UIViewController = self.navigationController!.viewControllers.last!;
            if let canConfigureVc = vc as? CanConfigureEconomyProtocol {
                canConfigureVc.sameEconomySet();
                return;
            }
            return;
        }
        
        //Ensure last view controller can configure economy.
        if vc is CanConfigureEconomyProtocol {
            //Ask for confirmation.
            let alert = UIAlertController(title: "Change Economy", message: "The app is configured for \(kEconomy.tokenName!) economy. Would you like to switch to \(gTokenName) economy?", preferredStyle: .alert);
            
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {[weak vc] (_) in
                let canConfigureVc = vc as? CanConfigureEconomyProtocol;
                CurrentEconomy.getInstance.economyDetails = economyPayload! as [String : Any];
                canConfigureVc?.newEconomySet(payload: economyPayload!);
                canConfigureVc?.clearAppUrlData();
            }));
            
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: {[weak vc] (_) in
                let canConfigureVc = vc as? CanConfigureEconomyProtocol;
                canConfigureVc?.newEconomyNotSet();
                canConfigureVc?.clearAppUrlData();
            }));
            vc.present( alert, animated: true, completion: nil);
            return;
        }

        //view controller can NOT configure economy.
        //-- Show alert to logout.
        //-- clear app url data.
        let alert = UIAlertController(title: "", message: "You appear to be logged in to another economy, please log out of the application and try connecting again.", preferredStyle: .alert);
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil));

        vc.present( alert, animated: true, completion: nil);
        self.clearAppUrlData();
    }
    
    func normalFlow() {
        if ( hasPerformedNormalFlow ) {
            return;
        }
        if nil != CurrentEconomy.getInstance.tokenId && fetchUser && !isUserFetched {
            getUserFromServer()
            isUserFetched = true
        }
        hasPerformedNormalFlow = true;
    }
    
    // MARK - Subviews
    let logoImageView: UIImageView = {
        let view = UIImageView(image: UIImage.init(named: "ostLogoBlue") );
        view.translatesAutoresizingMaskIntoConstraints = false
        return view;
    }()
    
    let leadLabel: UILabel = {
        let view = OstUIKit.leadLabel();
        //view.text = "Test your Brand Token Economy deployed on OST Platform";
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
        openSetupUserVC();
    }
    
    func openSetupUserVC() {
        let createAccountVC = SetupUserViewController()
        createAccountVC.viewControllerType = .signup;
        createAccountVC.pushViewControllerOn(self)
    }
    
    func openLoginUserVC() {
        let createAccountVC = SetupUserViewController()
        createAccountVC.viewControllerType = .login;
        createAccountVC.pushViewControllerOn(self)
    }
    
    @objc func loginButtonTapped(_ sender: Any?) {
        openLoginUserVC()
    }

    func getUserFromServer() {
        progressIndicator = OstProgressIndicator(textCode: .fetchingUser)
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
        if nil != CurrentUserModel.getInstance.ostUser
            && CurrentUserModel.getInstance.isCurrentUserStatusActivating! {
            
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
                    self?.pushToTabBarController()
                }
        }
    }
    
    func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        
    }
}
