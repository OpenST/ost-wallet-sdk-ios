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

class SetupUserViewController: OstBaseScrollViewController, UITextFieldDelegate {

    //MARK: - Components
    var testEconomyTextField: MDCTextField = {
        let testEconomyTextField = MDCTextField()
        testEconomyTextField.translatesAutoresizingMaskIntoConstraints = false
        testEconomyTextField.clearButtonMode = .never
        testEconomyTextField.placeholderLabel.text = "Test Economy"
        return testEconomyTextField
    }()
    var testEconomyTextFieldController: MDCTextInputControllerOutlined? = nil
    
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
        let button = OstUIKit.secondaryButton()
        return button
    }()
    
    var haveAccountLabel: UILabel = {
        let view = UILabel()
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
    
    var viewControllerType: SetupUserControllerType! {
        didSet {
            setupViewAccordingToType()
        }
    }
    
    var economyScanner: EconomyScannerViewController? = nil
    var appTabBarContoller = TabBarViewController()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let currentUser = CurrentUserModel.getInstance.ostUser {
            if currentUser.isStatusActivating {
                appTabBarContoller.pushViewControllerOn(self.navigationController!)
            }
        }
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
//        addSubview(haveAccountLabel)
        addSubview(changeTypeButton)
        
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
//        addHaveAccountLabelConstraints()
        addChangeTypeButtonConstraints()
        
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
        haveAccountLabel.placeBelow(toItem: setupButton, constant: 1)
        haveAccountLabel.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addChangeTypeButtonConstraints() {
        changeTypeButton.placeBelow(toItem: setupButton, constant: 10)
        changeTypeButton.centerXAlignWithParent()
    }
    
    //MARK: - Actions
    
    @objc func setupButtonTapped(_ sender: Any?) {
        
        if !isCorrectInputPassed() {
            return
        }
        
        if viewControllerType == .signup {
            CurrentUserModel.getInstance.signUp(username: self.usernameTextField.text!,
                                                phonenumber: self.passwordTextField.text!,
                                                onSuccess: {[weak self] (ostUser, ostDevice) in
                            self?.onSignupSuccess()
            }) { (isFailed) in
                
            }
        }else if viewControllerType == .login {
            CurrentUserModel.getInstance.login(username: self.usernameTextField.text!,
                phonenumber: self.passwordTextField.text!,
                onSuccess: {[weak self] (ostUser, ostDevice) in
                    self?.onLoginSuccess()
            }) { (isFailed) in
                
            }
        }
    }
    
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
    

    @objc func changeTypeTapped(_ sender: Any?) {
        viewControllerType = (viewControllerType == .signup) ? .login : .signup
    }
    
    //MARK: - Text Field Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === testEconomyTextField {
            openEconomyScanner(animation: true)
            return false
        }
        
        return true
    }
    
    func openEconomyScanner(animation flag: Bool) {
        if nil == economyScanner {
            economyScanner = EconomyScannerViewController()
        }
        self.navigationController?.present(economyScanner!, animated: flag, completion: nil)
    }
    
    func onSignupSuccess() {
        let currentUse = CurrentUserModel.getInstance
        _ = OstSdkInteract.getInstance.activateUser(userId: currentUse.ostUserId!,
                                                                       passphrasePrefixDelegate: currentUse,
                                                                       presenter: self)
    }
    
    func onLoginSuccess() {
        guard let currentDevice = CurrentUserModel.getInstance.userDevice else {return}
        if currentDevice.isStatusRegistered {
            if let currentUser = CurrentUserModel.getInstance.ostUser {
                if currentUser.isStatusActivated {
                    let authorizeDeviceVC = AuthorizeDeviceViewController()
                    authorizeDeviceVC.pushViewControllerOn(self)
                    return
                }
            }
            onSignupSuccess()
            return
        }
        
        appTabBarContoller.pushViewControllerOn(self.navigationController!)
    }
}
