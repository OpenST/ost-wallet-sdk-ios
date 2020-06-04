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
import LocalAuthentication

class SetupUserViewController: OstBaseScrollViewController, UITextFieldDelegate, OstFlowInterruptedDelegate, OstRequestAcknowledgedDelegate, OstFlowCompleteDelegate, CanConfigureEconomyProtocol {
    
    var appUrlData:AppUrlData? {
        let delegate = UIApplication.shared.delegate as! AppDelegate;
        return delegate.getWebPageUrl();
    };

    func defaultEconomySet(payload: [String : Any?]) {
        //Update the display details.
        updateEconomyDetails();
        //Close the economyScanner if open.
        economyScanner?.dismiss(animated: true, completion: nil);
    }
    
    func newEconomySet(payload: [String : Any?]) {
        //Update the display details.
        updateEconomyDetails();
        //Close the economyScanner if open.
        economyScanner?.dismiss(animated: true, completion: nil);
    }
    
    func newEconomyNotSet() {
        //Do nothing. Let the economyScanner be open if it was already open.
    }
    
    func sameEconomySet() {
        //Update the display details.
        updateEconomyDetails();
        //Close the economyScanner if open.
        economyScanner?.dismiss(animated: true, completion: nil);
    }
    
    func clearAppUrlData() {
        let delegate = UIApplication.shared.delegate as! AppDelegate;
        delegate.clearWebPageUrl();
    }
    
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
        passwordTextField.clearButtonMode = .never
        passwordTextField.isSecureTextEntry = true
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
        view.font = OstTheme.fontProvider.get(size: 14)
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
    
    var svContentViewHeightConstraint: NSLayoutConstraint? = nil
    
    //MARK: - View LC
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        if nil == CurrentEconomy.getInstance.tokenId {
            openEconomyScanner(animation: false)
        }
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateEconomyDetails();
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.economyScanner = nil
    }
    
    func updateEconomyDetails() {
        self.testEconomyTextField.text = CurrentEconomy.getInstance.tokenName ?? "";
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
        qrCodeButton.addTarget(weakSelf, action: #selector(weakSelf!.qrButtonTapped(_ :)), for: .touchUpInside)
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
        
        svContentViewHeightConstraint = svContentView.heightAnchor.constraint(equalToConstant: getContentViewHeight())
        svContentViewHeightConstraint?.isActive = true
    }
    
    func addTestEconomyTextFieldConstraints() {
        testEconomyTextField.topAlignWithParent(multiplier: 1, constant: 35)
        testEconomyTextField.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addQrCodeImageConstraints() {
        qrCodeButton.rightAlign(toItem: testEconomyTextField, constant: -8)
        qrCodeButton.centerAlignY(toItem: testEconomyTextField)
        qrCodeButton.setFixedWidth(constant: 40)
        qrCodeButton.setFixedHeight(constant: 40)
    }
    
    func addUsernameTextFieldConstraints() {
        usernameTextField.placeBelow(toItem: testEconomyTextField, constant: 10)
        usernameTextField.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addPasswordTextFieldConstraints() {
        passwordTextField.placeBelow(toItem: usernameTextField, constant: 10)
        passwordTextField.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addSetupButtonConstraints() {
        setupButton.placeBelow(toItem: passwordTextField, constant: 16)
        setupButton.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addHaveAccountLabelConstraints() {
        haveAccountLabel.bottomFromTopAlign(toItem: changeTypeButton, constant: -10)
        haveAccountLabel.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addChangeTypeButtonConstraints() {
        changeTypeButton.bottomAlignWithParent()
        changeTypeButton.centerXAlignWithParent()
    }
    
    func getContentViewHeight() -> CGFloat {
        return svContentView.getHeightConstant(forHeight: 570)
    }
    
    func getContentViewMinHeight() -> CGFloat {
        return 450
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
           signupUser()
        }else if viewControllerType == .login {
           loginUser()
        }
    }
    
    func signupUser() {
        CurrentUserModel.getInstance.signUp(username: self.usernameTextField.text!,
                                            phonenumber: self.passwordTextField.text!,
                                            onSuccess: {[weak self] (ostUser, ostDevice) in
                                                self?.onSignupSuccess()
        }) {[weak self] (apiError) in
            self?.onSigupFailed(apiError)
        }
    }
    
    func loginUser() {
        CurrentUserModel.getInstance.login(username: self.usernameTextField.text!,
                                           phonenumber: self.passwordTextField.text!,
                                           onSuccess: {[weak self] (ostUser, ostDevice) in
                                            
                                            if ostUser.isStatusCreated {
                                                self?.activateUser()
                                            }else {
                                                self?.onLoginSuccess()
                                            }
        }) {[weak self] (apiError) in
           
            self?.onLoginFailed(apiError)
        }
    }
    
    //MARK: - Validate Inputs
    func isCorrectInputPassed() -> Bool {
        let isValidUsename = validateUserNameTextField()
        let isValidPassword = validatePasswordTextField()
        return isValidUsename && isValidPassword
    }
    
    func validateUserNameTextField() -> Bool {
        if usernameTextField.text!.count > 0 && (usernameTextField.text?.isMatch("^[a-zA-Z0-9]*$") ?? false) {
            usernameTextFieldController?.setErrorText(nil, errorAccessibilityValue: nil);
            return true
        }
        usernameTextFieldController?.setErrorText("Username should be alphanumeric only.",
                                                  errorAccessibilityValue: nil);
        return false;
    }
    
    func validatePasswordTextField() -> Bool {
        if nil == passwordTextField.text
            || !passwordTextField.text!.isMatch("^[a-zA-Z0-9@#$%!*&]*$")
            || passwordTextField.text!.count < 8 {
            
            passwordTextFieldController?.setErrorText("Please enter a min of 8 chars. Letters, numbers and @ # $ % ! * & are allowed",
                                                      errorAccessibilityValue: nil);
            return false
        }
        
       
        passwordTextFieldController?.setErrorText(nil,errorAccessibilityValue: nil);
        return true
    }
    
    //MARK: - On Callback Complete
    func onSignupSuccess() {
       activateUser()
    }
    
    func activateUser() {
        removeProgressIndicator()
        
        
        let continueWorkflow: ((UIAlertAction?) -> Void) = {[weak self] (_) in
            let currentUse = CurrentUserModel.getInstance
            self!.workflowCallback = OstSdkInteract.getInstance.activateUser(userId: currentUse.ostUserId!,
                                                                       passphrasePrefixDelegate: currentUse,
                                                                       presenter: self!)
            OstSdkInteract.getInstance.subscribe(forWorkflowId: self!.workflowCallback!.workflowId,
                                                 listner: self!)
        }
        
        continueWorkflow(nil)
    }
    
    func onSigupFailed(_ apiError: [String: Any]?) {
        removeProgressIndicator()
        showErrorForSetup(apiError)
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
    
    func onLoginFailed(_ apiError: [String: Any]?) {
        removeProgressIndicator()
        
        showErrorForSetup(apiError)
    }
    
    func showErrorForSetup(_ apiError: [String: Any]?) {
        if let err = apiError?["err"] as? [String: Any],
            let code = err["code"] as? String {
            if code == "BAD_GATEWAY" {
                let msg = "Server temporarily unavailable"
                OstErroNotification.showNotification(withMessage: msg)
            }
        }
    }

    @objc func changeTypeTapped(_ sender: Any?) {
        viewControllerType = (viewControllerType == .signup) ? .login : .signup
    }
    
    @objc func qrButtonTapped(_ sender: Any?) {
        openEconomyScanner(animation: true)
    }
    
   @objc func openEconomyScanner(animation flag: Bool = true) {
        if nil == economyScanner {
            economyScanner = EconomyScannerViewController()
        }
		economyScanner!.modalPresentationStyle = .overFullScreen
        self.navigationController?.present(economyScanner!, animated: flag, completion: nil)
    }
    
    //MARK: - Text Field Delegate
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField === testEconomyTextField {
            openEconomyScanner()
            return false
        }
        
        return true
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
        var messageCode: OstProgressIndicatorTextCode = .unknown
        if viewControllerType == .signup {
            messageCode = .signup
        }else if viewControllerType == .login {
            messageCode = .login
        }
        
        progressIndicator = OstProgressIndicator(textCode: messageCode)
        progressIndicator?.show()
    }
    
    func removeProgressIndicator() {
        progressIndicator?.hide()
        progressIndicator = nil
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
    
    //MAKR: - Keyboard Notificaiton
    @objc func keyboardWillShow(_ notification:Notification) {
        
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        let svContentViewHeight:CGFloat = getContentViewHeight() - keyboardHeight
        svContentViewHeightConstraint?.constant = max(getContentViewMinHeight(), svContentViewHeight)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        svContentViewHeightConstraint?.constant = getContentViewHeight()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
