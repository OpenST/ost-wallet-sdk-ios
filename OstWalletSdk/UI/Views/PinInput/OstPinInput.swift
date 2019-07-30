/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

@objc public protocol OstPinInputDelegate: class {
    /// Called when the pin of required length has been entered.
    ///
    /// - Parameter pin: `pin` user pin as string.
    @objc
    func pinProvided(pin:String);
}

class OstPinInput: UIView, UITextFieldDelegate {
    
    public let dotRadius:CGFloat = 6.0;
    public let verticalPadding:CGFloat = 10.0;
    public let gutterWidth:CGFloat = 24.0;
    public let dotEmptyColor = UIColor.color(199, 199, 204);
    public let dotFilledColor = UIColor.color(22, 141, 193);
    public let wrapBackgroundColor = UIColor.white;
    public let pinLength = 6;
    public var delegate:OstPinInputDelegate?


    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect) {
        super.init(frame: frame);
        performInit();
    }
    
    deinit {
        print("deinit: \(String(describing: self) )")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder);
        performInit();
    }
    
    func performInit() {
        styleSelf();
        createPinTextField();
        createWrap();
        createDots();
        self.sendSubviewToBack( pinTextField );
        self.bringSubviewToFront( wrapView );
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.wrapViewTapDetected))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
    }

    func styleSelf() {
        self.translatesAutoresizingMaskIntoConstraints = false;
        let dotDiameter:CGFloat = (2 * dotRadius);
        let viewHeight:CGFloat = dotDiameter + (2 * verticalPadding );
        self.clipsToBounds = true;
        self.setFixedHeight(constant: viewHeight );
        
        // The magic number (1 + pinLength): We have (pinLength - 1) gutters between pinLength dots
        // and one on the left side of first dot (acts as left padding)
        // and one on the right side of last dot (acts as right padding)
        let viewWidth:CGFloat = (CGFloat(1 + pinLength) * gutterWidth)
            + (CGFloat(pinLength) * dotDiameter);
        self.setFixedWidth(constant: viewWidth);
    }
    
    
    fileprivate let pinTextField = UITextField();
    fileprivate func createPinTextField() {
        self.addSubview( pinTextField );
        pinTextField.keyboardType = .numberPad;
        pinTextField.isSecureTextEntry = true;
        pinTextField.delegate = self;
        pinTextField.translatesAutoresizingMaskIntoConstraints = false;
        self.addConstraint(
            NSLayoutConstraint(item: pinTextField,
                               attribute: .bottom,
                               relatedBy: .equal,
                               toItem: self,
                               attribute: .top,
                               multiplier: 1, constant: -10)
        );
        
        pinTextField.leftAlignWithParent(constant: 10);
        pinTextField.rightAlignWithParent(constant:-10);
        pinTextField.setFixedHeight(constant: 12);
        
        // Just incase constraints break.
        pinTextField.backgroundColor = UIColor.white;
        pinTextField.textColor = UIColor.white;
        pinTextField.tintColor = UIColor.white;
        pinTextField.alpha = 0.0;
        
        //Add the event listner.
        pinTextField.addTarget(self, action: #selector(pinTextFieldDidChange(textField:)), for: .editingChanged);
    }
    
    fileprivate let wrapView:UIView = UIView();
    fileprivate func createWrap() {
        self.addSubview( wrapView );
        wrapView.translatesAutoresizingMaskIntoConstraints = false;
        wrapView.topAlignWithParent();
        wrapView.leftAlignWithParent();
        wrapView.rightAlignWithParent();
        wrapView.bottomAlignWithParent();
        wrapView.backgroundColor = wrapBackgroundColor;
        self.bringSubviewToFront(wrapView);
    }
    
    @objc func wrapViewTapDetected() {
        _ = becomeFirstResponder()
    }
    
    var dots:[UIView] = [];
    func createDots() {
        var prevView:UIView? = nil;
        for _ in 1...pinLength {
            let dotView = createDotView();
            wrapView.addSubview( dotView );
            dots.append( dotView );
            if ( nil == prevView ) {
                dotView.leftAlign(toItem: wrapView, constant: gutterWidth);
            } else {
                dotView.leftWithRightAlign(toItem: prevView!, constant: gutterWidth);
            }
            
            dotView.centerYAlignWithParent();
            prevView = dotView;
        }
        //Add right gutter.
        prevView!.rightAlignWithParent(constant: (-1 * gutterWidth) );
    }
    
    func createDotView() -> UIView {
        let view = UIView();
        let dotDiameter:CGFloat = (2 * dotRadius);
        view.translatesAutoresizingMaskIntoConstraints = false;
        view.setFixedWidth(constant: dotDiameter);
        view.setFixedHeight(constant: dotDiameter);
        view.layer.cornerRadius = dotRadius;
        view.backgroundColor = dotEmptyColor;
        return view;
    }
    
    func updateDots(currentPinLength:Int) {
        for cnt in 1...pinLength {
            let dot = dots[cnt - 1];
            if ( cnt <=  currentPinLength) {
                dot.backgroundColor = dotFilledColor;
            } else {
                dot.backgroundColor = dotEmptyColor;
            }
        }
    }
    
    override func becomeFirstResponder() -> Bool {
        return pinTextField.becomeFirstResponder();
    }
    
    override func resignFirstResponder() -> Bool {
        return pinTextField.resignFirstResponder();
    }
    
    override var canBecomeFirstResponder: Bool {
        get {
            return pinTextField.canBecomeFirstResponder;
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if ( textField != pinTextField ) {
            //Dont care.
            return true;
        }
        
        if ( pinTextField.text!.count == pinLength ) {
            //We have the pin.
            return true;
        } else {
            return false;
        }
    }
    
//    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
//        if ( textField != pinTextField ) {
//            //Dont care.
//            return true;
//        }
//
//        if ( pinTextField.text!.count == pinLength ) {
//            //We have the pin.
//            return true;
//        } else {
//            return false;
//        }
//    }
    
    @objc func pinTextFieldDidChange(textField: UITextField) -> Void {
        if (textField != pinTextField ) {
            //Dont care.
            return;
        }
        let pin = pinTextField.text!;
        let currentPinLength = pin.count;
        updateDots(currentPinLength: currentPinLength);
        if (currentPinLength == pinLength ) {
            pinTextField.endEditing(true);
            pinTextField.text = "";
            //We are done.
            self.delegate?.pinProvided(pin: pin);
        }
    }
    
    @objc func resetView() {
        DispatchQueue.main.async { [weak self] in
            self?.pinTextField.text = "";
            self?.updateDots(currentPinLength: 0);
        }
    }
    
}


