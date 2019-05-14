/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import MaterialComponents
import OstWalletSdk

class SetupUserViewController: OstBaseScrollViewController, UITextFieldDelegate, OstFlowInterruptedDelegate, OstRequestAcknowledgedDelegate, OstFlowCompleteDelegate {
    
    //MARK: - Components
    var testEconomyTextField: MDCTextField = {
        let testEconomyTextField = MDCTextField()
        testEconomyTextField.translatesAutoresizingMaskIntoConstraints = false
        testEconomyTextField.clearButtonMode = .never
        testEconomyTextField.placeholderLabel.text = "Test Economy"
        return testEconomyTextField
    }()
    var testEconomyTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var qrCodeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "QrcodeImage"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        return btn
    }()
    
    var usernameTextField: MDCTextField = {
        let usernameTextField = MDCTextField()
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        usernameTextField.clearButtonMode = .never
        usernameTextField.placeholderLabel.text = "Username"
        return usernameTextField
    }()
    var usernameTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var passwordTextField: MDCTextField = {
        let passwordTextField = MDCTextField()
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.clearButtonMode = .unlessEditing
        passwordTextField.placeholderLabel.text = "Password"
        return passwordTextField
    }()
    var passwordTextFieldController: MDCTextInputControllerOutlined? = nil
    
    var setupButton: UIButton = {
        let button = OstUIKit.primaryButton()
        return button
    }()
    
    var changeTypeButton: UIButton = {
        let button = OstUIKit.linkButton()
        return button
    }()
    
    var haveAccountLabel: UILabel = {
        let view = UILabel()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.numberOfLines = 1
        view.textAlignment = .center
        view.text = "a"
        view.font = OstFontProvider().get(size: 14)
        view.textColor = UIColor.color(136, 136, 136)
        return view
    }()
    
    //MARK: - Variables
    enum SetupUserControllerType {
        case signup, login
    }
    
    var progressIndicator: OstProgressIndicator? = nil
    
    var viewControllerType: SetupUserControllerType! {
        didSet {
            setupViewAccordingToType()
        }
    }
    
    var economyScanner: EconomyScannerViewController? = nil
    var appTabBarContoller: TabBarViewController? = nil
    func getAppTabBarContoller() -> TabBarViewController {
        return TabBarViewController()
    }
    
    var workflowCallback: OstWorkflowCallbacks? = nil
    
    //MARK: - View LC
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
   
        if let economy = UserDefaults.standard.string(forKey: CurrentEconomy.userDefaultsId),
            let qrJsonData = EconomyScannerViewController.getQRJsonData(economy) {
            CurrentEconomy.getInstance.economyDetails = qrJsonData as [String : Any]
        }
        
        if nil == CurrentEconomy.getInstance.tokenId {
            openEconomyScanner(animation: false)
            return
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.testEconomyTextField.text = CurrentEconomy.getInstance.tokenName ?? ""
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.economyScanner = nil
    }
    
    //MARK: - Add SubView
    
    override func addSubviews() {
        super.addSubviews()
       
        setupTextFields()
        setupButtonActions()

        setupViewAccordingToType()

        addSubview(usernameTextField)
        addSubview(testEconomyTextField)
        addSubview(passwordTextField)
        addSubview(setupButton)
        addSubview(haveAccountLabel)
        addSubview(changeTypeButton)
        addSubview(qrCodeButton)
    }
    
    func setupTextFields() {
        self.usernameTextFieldController = MDCTextInputControllerOutlined(textInput: usernameTextField)
        self.testEconomyTextFieldController = MDCTextInputControllerOutlined(textInput: testEconomyTextField)
        self.passwordTextFieldController = MDCTextInputControllerOutlined(textInput: passwordTextField)
        
        self.testEconomyTextField.delegate = self;
    }
    
    func setupButtonActions() {
        weak var weakSelf = self
        setupButton.addTarget(weakSelf, action: #selector(weakSelf!.setupButtonTapped(_:)), for: .touchUpInside)
        changeTypeButton.addTarget(weakSelf, action: #selector(weakSelf!.changeTypeTapped(_:)), for: .touchUpInside)
        qrCodeButton.addTarget(weakSelf, action: #selector(weakSelf!.openEconomyScanner(animation:)), for: .touchUpInside)
    }
    
    func setupViewAccordingToType() {
        if viewControllerType == .signup {
            setupUIForSignup()
        }
        else if viewControllerType == .login {
            setupUIForLogin()
        }
    }
    
    func setupUIForLogin() {
        self.title = "Log in to your Account"
        self.setupButton.setTitle("Log In", for: .normal)
        self.haveAccountLabel.text = "Don’t have an account?"
        self.changeTypeButton.setTitle("Create an account", for: .normal)
    }
    
    func setupUIForSignup() {
        self.title = "Create Your Account"
        self.setupButton.setTitle("Create Account", for: .normal)
        self.haveAccountLabel.text = "Already have an account?"
        self.changeTypeButton.setTitle("Log in", for: .normal)
    }
    
    //MARK: - Add Constraints
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
       
        addTestEconomyTextFieldConstraints()
        addUsernameTextFieldConstraints()
        addPasswordTextFieldConstraints()
        addSetupButtonConstraints()
        addHaveAccountLabelConstraints()
        addChangeTypeButtonConstraints()
        addQrCodeImageConstraints()
        
        let last = changeTypeButton
        last.bottomAlignWithParent()
    }
    
    func addTestEconomyTextFieldConstraints() {
        testEconomyTextField.topAlignWithParent(multiplier: 1, constant: 35)
        testEconomyTextField.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addUsernameTextFieldConstraints() {
        usernameTextField.placeBelow(toItem: testEconomyTextField, constant: 1)
        usernameTextField.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addPasswordTextFieldConstraints() {
        passwordTextField.placeBelow(toItem: usernameTextField, constant: 1)
        passwordTextField.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addSetupButtonConstraints() {
        setupButton.placeBelow(toItem: passwordTextField, constant: 1)
        setupButton.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addHaveAccountLabelConstraints() {
        haveAccountLabel.bottomFromTopAlign(toItem: changeTypeButton, constant: -10)
        haveAccountLabel.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addChangeTypeButtonConstraints() {
        let guide = view.safeAreaLayoutGuide
        changeTypeButton.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant:-10).isActive = true
        changeTypeButton.centerXAlignWithParent()
    }
    
    func addQrCodeImageConstraints() {
        qrCodeButton.rightAlign(toItem: testEconomyTextField, constant: -8)
        qrCodeButton.centerAlignY(toItem: testEconomyTextField)
        qrCodeButton.setFixedWidth(constant: 40)
        qrCodeButton.setFixedHeight(constant: 40)
    }
    
    //MARK: - Actions
    
    @objc func setupButtonTapped(_ sender: Any?) {
        
        if nil == CurrentEconomy.getInstance.saasApiEndpoint {
            self.view.endEditing(true)
            openEconomyScanner()
            return
        }
        
        if !isCorrectInputPassed() {
            return
        }
        self.view.endEditing(true)
        showProgressIndicator()
        
        try! OstWalletSdk.initialize(apiEndPoint: CurrentEconomy.getInstance.saasApiEndpoint ?? "")
        
        if viewControllerType == .signup {
            CurrentUserModel.getInstance.signUp(username: self.usernameTextField.text!,
                                                phonenumber: self.passwordTextField.text!,
                                                onSuccess: {[weak self] (ostUser, ostDevice) in
                            self?.onSignupSuccess()
            }) {[weak self] (isFailed) in
                self?.onSigupFailed()
            }
        }else if viewControllerType == .login {
            CurrentUserModel.getInstance.login(username: self.usernameTextField.text!,
                phonenumber: self.passwordTextField.text!,
                onSuccess: {[weak self] (ostUser, ostDevice) in
                    self?.onLoginSuccess()
            }) {[weak self] (isFailed) in
                self?.onLoginFailed()
            }
        }
    }
    
    //MARK: - Validate Inputs
    func isCorrectInputPassed() -> Bool {
        let isValidUsename = validateUserNameTextField()
        let isValidPassword = validatePasswordTextField()
        return isValidUsename || isValidPassword
    }
    
    func validateUserNameTextField() -> Bool {
        if usernameTextField.text?.isMatch("a-zA-Z0-9") ?? false {
            usernameTextFieldController?.setErrorText("Invalid username",
                                                      errorAccessibilityValue: nil);
            return false;
        }
        usernameTextFieldController?.setErrorText(nil,errorAccessibilityValue: nil);
        return true
    }
    
    func validatePasswordTextField() -> Bool {
        if nil == passwordTextField.text
            || passwordTextField.text!.isMatch("a-zA-Z0-9")
            || passwordTextField.text!.count < 5 {
            
            usernameTextFieldController?.setErrorText("Invalid password",
                                                      errorAccessibilityValue: nil);
            return false;
        }
        usernameTextFieldController?.setErrorText(nil,errorAccessibilityValue: nil);
        return true
    }
    
    //MARK: - On Callback Complete
    func onSignupSuccess() {
        removeProgressIndicator()
        let currentUse = CurrentUserModel.getInstance
        workflowCallback = OstSdkInteract.getInstance.activateUser(userId: currentUse.ostUserId!,
                                                                   passphrasePrefixDelegate: currentUse,
                                                                   presenter: self)
        OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowCallback!.workflowId,
                                             listner: self)
    }
    
    func onSigupFailed() {
        removeProgressIndicator()
    }
    
    func onLoginSuccess() {
        removeProgressIndicator()
        pushToTabBarController()
    }
    
    func onLoginFailed() {
        removeProgressIndicator()
    }
    

    @objc func changeTypeTapped(_ sender: Any?) {
        viewControllerType = (viewControllerType == .signup) ? .login : .signup
    }
    
    //MARK: - Text Field Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === testEconomyTextField {
            openEconomyScanner()
            return false
        }
        
        return true
    }
    
    @objc func openEconomyScanner(animation flag: Bool = true) {
        if nil == economyScanner {
            economyScanner = EconomyScannerViewController()
        }
        self.navigationController?.present(economyScanner!, animated: flag, completion: nil)
    }

    func pushToTabBarController() {
        if nil != workflowCallback {
            OstSdkInteract.getInstance.unsubscribe(forWorkflowId: workflowCallback!.workflowId,
                                                   listner: self)
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.showTabbarController(workflowCallback)
        workflowCallback = nil
    }
    
    func showProgressIndicator() {
        var message: String = ""
        if viewControllerType == .signup {
            message = "Siging up"
        }else if viewControllerType == .login {
            message = "Loging in"
        }
        
        if let window = UIApplication.shared.keyWindow {
            progressIndicator = OstProgressIndicator(progressText: message)
            window.addSubview(progressIndicator!)
            progressIndicator?.show()
        }
    }
    
    func removeProgressIndicator() {
        progressIndicator?.hide()
        progressIndicator = nil
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