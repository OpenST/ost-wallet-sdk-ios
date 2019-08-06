/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

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
    
    let infoLabel: OstH3Label = {
        return OstH3Label(text: "")
    }()
    
    let pinInput: OstPinInput = {
        let view = OstPinInput();
        return view;
    }();
    
    let termsAndConditionLabel: OstH4Label = {
        let label = OstH4Label()
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
        
        pinVCConfig?.updateLabelWithAttributedText(label: titleLabel, data: pinVCConfig!.titleLabelData)
        pinVCConfig?.updateLabelWithAttributedText(label: leadLabel, data: pinVCConfig!.leadLabelData)
        pinVCConfig?.updateLabelWithAttributedText(label: infoLabel, data: pinVCConfig!.infoLabelData)
        pinVCConfig?.updateLabelWithAttributedText(label: termsAndConditionLabel, data: pinVCConfig!.tcLabelData)
    }
    
    override func addSubviews() {
        super.addSubviews();
        
        let labelArray = [titleLabel, leadLabel, infoLabel, termsAndConditionLabel]
        
        for label in labelArray {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_ :)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.delegate = self
            
            label.addGestureRecognizer(tapGesture)
            
            self.addSubview(label)
        }
        
        self.addSubview( pinInput );
    }
    
    @objc func linkLabelTapped(attributes: [NSAttributedString.Key: Any]) {
        if let urlString = attributes[NSAttributedString.Key(rawValue: "url")] as? String {
            let webview = WKWebViewController()
            webview.urlString = urlString
            webview.presentVCWithNavigation()
        }
    }
    
    @objc func labelTapped(_ recognizer: UITapGestureRecognizer) {
        
        let label = recognizer.view as! UILabel
        let textView: UITextView = UITextView(frame: label.frame)
        textView.attributedText = label.attributedText
        
        let layoutManager: NSLayoutManager = textView.layoutManager
        var location = recognizer.location(in: label)
        location.x -= textView.textContainerInset.left;
//        location.y -= textView.textContainerInset.top;
        
        let characterIndex: Int = layoutManager.characterIndex(for: location,
                                                               in: textView.textContainer,
                                                               fractionOfDistanceBetweenInsertionPoints: nil)
        
        if (characterIndex < textView.textStorage.length) {
            let attributes = textView.textStorage.attributes(at: characterIndex, effectiveRange: nil)
            linkLabelTapped(attributes: attributes)
        }
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints();
        
        titleLabel.topAlignWithParent(multiplier: 1, constant: 20.0)
        titleLabel.applyBlockElementConstraints(horizontalMargin: 40)
        
        leadLabel.placeBelow(toItem: titleLabel)
        leadLabel.applyBlockElementConstraints(horizontalMargin: 40)
        
        infoLabel.placeBelow(toItem: leadLabel, constant: 4.0)
        infoLabel.applyBlockElementConstraints(horizontalMargin: 40)
        
        pinInput.placeBelow(toItem: infoLabel, constant: 20.0);
        pinInput.centerXAlignWithParent();
        
        
        termsAndConditionLabel.applyBlockElementConstraints(horizontalMargin: 40);
//        termsAndConditionLabel.setFixedHeight(constant: 55)
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
