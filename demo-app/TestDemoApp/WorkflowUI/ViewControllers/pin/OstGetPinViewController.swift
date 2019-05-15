/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
*/

import UIKit
import OstWalletSdk;


class OstGetPinViewController: OstBaseScrollViewController {
    
    
    public class func newInstance(pinInputDelegate: OstPinInputDelegate) -> OstGetPinViewController {
        let instance = OstGetPinViewController();
        setEssentials(instance: instance, pinInputDelegate: pinInputDelegate);
        return instance;
    }
    
    class func setEssentials(instance:OstGetPinViewController, pinInputDelegate:OstPinInputDelegate) {
        instance.pinInputDelegate = pinInputDelegate;
    }
    
    
    internal var pinInputDelegate:OstPinInputDelegate?;
    private var contentViewHeightConstraint: NSLayoutConstraint? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad();
        validateViewController();

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

//        pinInput.delegate = self.pinInputDelegate!;
        // Do any additional setup after loading the view.
    }
    
    deinit {
        
    }
    
    override func getNavBarTitle() -> String {
        return "Enter Pin";
    }
    
    let leadLabel: UILabel = {
        let view = OstUIKit.leadLabel();
        view.text = "Enter you 6-digit PIN to authorize \n your action.";
        view.backgroundColor = .white;
        view.numberOfLines = 4;
        return view;
    }()
    
    let pinInput: OstPinInput = {
        let view = OstPinInput();
        return view;
    }();
    
    let termsAndConditionLabel: UILabel = {
        let label = UILabel()
        label.text = "here"
        label.translatesAutoresizingMaskIntoConstraints = false
        
        var labelThemer = OstLabelTheamer()
        labelThemer.fontSize = 12
        labelThemer.textAliginment = .center
        labelThemer.textColor = UIColor.color(136, 136, 136)
        
        labelThemer.apply(label)
        
        return label
    }()
    
    
    override func configure() {
        super.configure();
        self.shouldFireIsMovingFromParent = true;
    }
    
    override func addSubviews() {
        super.addSubviews();
        self.addSubview(leadLabel);
        self.addSubview( pinInput );
        self.addSubview(termsAndConditionLabel)
        
        setupTermsAndConditionLabel()
    }
    
    func setupTermsAndConditionLabel() {
        
        let attributedString = NSMutableAttributedString(string: "By Creating Your Wallet, you Agree to our\n")
        
        let attributes: [NSAttributedString.Key : Any] = [.font: OstFontProvider().get(size: 12).bold()]
        let termsAttributedString = NSAttributedString(string: "Terms of Service", attributes: attributes)
        let privacyAttributedString = NSAttributedString(string: "Privacy Policy", attributes: attributes)
        
        attributedString.append(termsAttributedString)
        attributedString.append(NSAttributedString(string: " and "))
        attributedString.append(privacyAttributedString)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        termsAndConditionLabel.attributedText = attributedString
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints();
        leadLabel.topAlignWithParent(constant: 20.0);
        leadLabel.centerXAlignWithParent();
        leadLabel.setFixedWidth(constant: 274.0);
        
        pinInput.placeBelow(toItem: leadLabel, constant: 20.0);
        pinInput.centerXAlignWithParent();
        
        termsAndConditionLabel.applyBlockElementConstraints();
        termsAndConditionLabel.bottomAlignWithParent()
        
        contentViewHeightConstraint = svContentView.heightAnchor.constraint(equalToConstant: getContentViewHeight())
        contentViewHeightConstraint?.isActive = true
    }
    
    func getContentViewHeight() -> CGFloat {
        return getHeightValue(forHeight: 590)
    }
    
    func getHeightValue(forHeight height: CGFloat) -> CGFloat {
        let windowHeight: CGFloat = 667.0;
        let multiplier = height / windowHeight;
        let window = UIApplication.shared.keyWindow;
        let heightConstant = (window?.frame.height)! * multiplier
        return heightConstant
    }
        
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        validateViewController();
        resetView();
        _ = pinInput.becomeFirstResponder();
    }
    

    fileprivate func validateViewController() {
//        if ( nil == self.pinInputDelegate ) {
//            fatalError("pinInputDelegate is nil. Please use `newInstance` method.");
//        }
    }
    
    public func resetView() {
        self.pinInput.resetView();
    }
    
    var defaultErrorMessage = "Invalid Pin";
    public func showInvalidPin(errorMessage: String? = nil) {
        self.resetView();
        _ = self.pinInput.becomeFirstResponder()
        var errMsgToShow = self.defaultErrorMessage;
        if ( nil != errorMessage ) {
            errMsgToShow = errorMessage!;
        }
        
        let alertController = UIAlertController(title: "Incorrect PIN", message: errMsgToShow, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }) )
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    //MAKR: - Keyboard Notificaiton
    @objc func keyboardWillShow(_ notification:Notification) {
        
        let userInfo:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        let svContentViewHeight = getContentViewHeight() - keyboardHeight
        contentViewHeightConstraint?.constant = svContentViewHeight
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
     @objc func keyboardWillHide(_ notification:Notification) {
        contentViewHeightConstraint?.constant = getContentViewHeight()
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
