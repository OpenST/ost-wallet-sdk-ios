/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk;


class OstPinViewController: OstBaseScrollViewController {
    
    public class func newInstance(pinInputDelegate: OstPinInputDelegate,
                                  pinVCConfig: OstPinVCConfig) -> OstPinViewController {
        
        let instance = OstPinViewController()
        setEssentials(instance: instance,
                      pinInputDelegate: pinInputDelegate,
                      pinVCConfig: pinVCConfig)
        
        return instance
    }
    
    class func setEssentials(instance: OstPinViewController,
                             pinInputDelegate:OstPinInputDelegate,
                             pinVCConfig: OstPinVCConfig) {
        
        instance.pinInputDelegate = pinInputDelegate
        instance.pinVCConfig = pinVCConfig
    }
    
    //MAKR: - Components
    
    let titleLabel: OstH1Label = {
        return OstH1Label(text: "")
    }()
    
    let leadLabel: OstH2Label = {
        return OstH2Label(text: "")
    }()
    
    let h3Label: OstH3Label = {
        return OstH3Label(text: "")
    }()
    
    let pinInput: OstPinInput = {
        let view = OstPinInput();
        return view;
    }();
    
    let termsAndConditionLabel: UITextView = {
        let label = UITextView()
        let h4Config = OstTheme.getInstance().getH4Config()
        label.isEditable = false
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = h4Config.getFont()
        label.textColor = h4Config.getColor()
        
        return label
    }()
    
    internal var pinInputDelegate:OstPinInputDelegate?;
    private var pinVCConfig: OstPinVCConfig? = nil
    private var contentViewHeightConstraint: NSLayoutConstraint? = nil
    private var isCallbackTriggered: Bool = false
    
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
    
    override func configure() {
        super.configure();
        self.shouldFireIsMovingFromParent = true;
        
        self.titleLabel.labelText = getTitleLabelText()
        self.leadLabel.labelText = getLeadLabelText()
        self.h3Label.labelText = getH3LabelText()
    }
    
    func getTitleLabelText() -> String {
        return pinVCConfig?.titleText ?? ""
    }
    
    func getLeadLabelText() -> String {
        return pinVCConfig?.leadLabelText ?? ""
    }
    
    func getH3LabelText() -> String {
        return pinVCConfig?.infoLabelText ?? ""
    }
    
    override func addSubviews() {
        super.addSubviews();
        self.addSubview(titleLabel)
        self.addSubview(leadLabel);
        self.addSubview(h3Label);
        self.addSubview( pinInput );
        self.addSubview(termsAndConditionLabel)
        
        if nil != pinVCConfig?.tcLabelText {
            setupTermsAndConditionLabel()
        }
    }
    
    func setupTermsAndConditionLabel() {
        
        let attributes: [NSAttributedString.Key : Any] = [.font: OstTheme.getInstance().getH4Config().getFont(),
                                                          .foregroundColor: OstTheme.getInstance().getH4Config().getColor() ]
        
        let attributedString = NSMutableAttributedString(string: "Your PIN will be used to authorise sessions, transactions, redemptions and recover wallet.",
                                                         attributes: attributes)
        
        var termsAttributes: [NSAttributedString.Key : Any]  = attributes
        termsAttributes[.init("action")] = #selector(self.LinkLabelTapped(attributes:))
        termsAttributes[.init("url")] = OstContent.getInstance().getTCURL()
        termsAttributes[.foregroundColor] = UIColor.color(0, 118, 255)
        let termsAttributedString = NSAttributedString(string: " T&C Apply", attributes: termsAttributes)
        
        attributedString.append(termsAttributedString)
        
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
    
    @objc func LinkLabelTapped(attributes: [NSAttributedString.Key: Any]) {
        let webview = WKWebViewController()
        webview.urlString = attributes[NSAttributedString.Key(rawValue: "url")] as! String
        webview.presentVCWithNavigation()
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
        
        titleLabel.topAlignWithParent(multiplier: 1, constant: 20.0)
        titleLabel.applyBlockElementConstraints()
        
        leadLabel.placeBelow(toItem: titleLabel)
        leadLabel.applyBlockElementConstraints()
        
        h3Label.placeBelow(toItem: leadLabel, constant: 4.0)
        h3Label.applyBlockElementConstraints()
        
        pinInput.placeBelow(toItem: h3Label, constant: 20.0);
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
