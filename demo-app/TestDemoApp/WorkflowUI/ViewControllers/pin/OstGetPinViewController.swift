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

        pinInput.delegate = self.pinInputDelegate!;
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    deinit {
        
    }
    
    override func getNavBarTitle() -> String {
        return "Enter Pin";
    }
    
    let leadLabel: UILabel = {
        let view = OstUIKit.leadLabel();
        view.backgroundColor = .white;
        view.numberOfLines = 4;
        return view;
    }()
    
    let pinInput: OstPinInput = {
        let view = OstPinInput();
        return view;
    }();
    
    let termsAndConditionLabel: UITextView = {
        let label = UITextView()
        label.isEditable = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = OstTheme.fontProvider.get(size: 12)
        label.textColor = UIColor.color(136, 136, 136)
        
        return label
    }()
    
    
    override func configure() {
        super.configure();
        self.shouldFireIsMovingFromParent = true;
        self.leadLabel.text = getLeadLabelText()
    }
    
    func getLeadLabelText() -> String {
        return "Enter you 6-digit PIN to authorize \n your action."
    }
    
    override func addSubviews() {
        super.addSubviews();
        self.addSubview(leadLabel);
        self.addSubview( pinInput );
        self.addSubview(termsAndConditionLabel)
        
        setupTermsAndConditionLabel()
    }
    
    func setupTermsAndConditionLabel() {
        let attributes: [NSAttributedString.Key : Any] = [.font: OstTheme.fontProvider.get(size: 12),
                                                          .foregroundColor: UIColor.color(136, 136, 136) ]
        
        let attributedString = NSMutableAttributedString(string: "By Creating Your Wallet, you Agree to our\n",
                                                         attributes: attributes)
        
        var termsAttributes: [NSAttributedString.Key : Any]  = attributes
        termsAttributes[.init("action")] = #selector(self.termsLabelTapped(attributes:))
        termsAttributes[.init("url")] = "https://drive.google.com/file/d/1QTZ7_EYpbo5Cr7sLdqkKbuwZu-tmZHzD/view"
        termsAttributes[.font] = OstTheme.fontProvider.get(size: 12).bold()
        let termsAttributedString = NSAttributedString(string: "Terms of Service", attributes: termsAttributes)
        
        var privacyAttributes: [NSAttributedString.Key : Any]  = attributes
        privacyAttributes[.init("action")] = #selector(self.privacyLabelTapped(attributes:))
        privacyAttributes[.init("url")] = "https://ost.com/privacy"
        privacyAttributes[.font] = OstTheme.fontProvider.get(size: 12).bold()
        let privacyAttributedString = NSAttributedString(string: "Privacy Policy", attributes: privacyAttributes)
        
        attributedString.append(termsAttributedString)
        attributedString.append(NSAttributedString(string: " and ", attributes: attributes))
        attributedString.append(privacyAttributedString)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        attributedString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))

        termsAndConditionLabel.attributedText = attributedString
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tncLabelTapped(_ :)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        termsAndConditionLabel.addGestureRecognizer(tapGesture)
    }
    
    @objc func termsLabelTapped(attributes: [NSAttributedString.Key: Any]) {
        let webview = WKWebViewController()
        webview.title = "Terms of Service"
        webview.urlString = attributes[NSAttributedString.Key(rawValue: "url")] as! String
        webview.presentViewControllerWithNavigationController(self)
    }
    
    @objc func privacyLabelTapped(attributes: [NSAttributedString.Key: Any]) {
        let webview = WKWebViewController()
        webview.title = "Privacy Policy"
        webview.urlString = attributes[NSAttributedString.Key(rawValue: "url")] as! String
        webview.presentViewControllerWithNavigationController(self)
    }
    
    @objc func tncLabelTapped(_ recognizer: UITapGestureRecognizer) {
        let textView: UITextView = recognizer.view as! UITextView
        
        let layoutManager: NSLayoutManager = textView.layoutManager
        var location = recognizer.location(in: textView)
        location.x -= textView.textContainerInset.left;
        location.y -= textView.textContainerInset.top;
        
        let characterIndex: Int = layoutManager.characterIndex(for: location,
                                                               in: textView.textContainer,
                                                               fractionOfDistanceBetweenInsertionPoints: nil)
    
        if (characterIndex < textView.textStorage.length) {
            let attributes = textView.textStorage.attributes(at: characterIndex, effectiveRange: nil)
            if let action = attributes[NSAttributedString.Key(rawValue: "action")] as? Selector,
                self.responds(to: action){
                
                self.perform(action, with: attributes)
            }
        }
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints();
        leadLabel.topAlignWithParent(constant: 20.0);
        leadLabel.centerXAlignWithParent();
        leadLabel.setFixedWidth(constant: 274.0);
        
        pinInput.placeBelow(toItem: leadLabel, constant: 20.0);
        pinInput.centerXAlignWithParent();
        
        termsAndConditionLabel.applyBlockElementConstraints();
        termsAndConditionLabel.setFixedHeight(constant: 45)
        termsAndConditionLabel.bottomAlignWithParent()
        
        contentViewHeightConstraint = svContentView.heightAnchor.constraint(equalToConstant: getContentViewHeight())
        contentViewHeightConstraint?.isActive = true
    }
    
    func getContentViewHeight() -> CGFloat {
        return svContentView.getHeightConstant(forHeight: 570)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        validateViewController();
        resetView();
        _ = pinInput.becomeFirstResponder();
    }
    

    fileprivate func validateViewController() {
        if ( nil == self.pinInputDelegate ) {
            fatalError("pinInputDelegate is nil. Please use `newInstance` method.");
        }
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
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: {[weak self] (action) in
            _ = self?.pinInput.becomeFirstResponder()
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
