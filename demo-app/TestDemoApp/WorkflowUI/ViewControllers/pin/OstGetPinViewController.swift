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
    
    override func viewDidLoad() {
        super.viewDidLoad();
        validateViewController();
        pinInput.delegate = self.pinInputDelegate!;
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
    
    
    override func configure() {
        super.configure();
        self.shouldFireIsMovingFromParent = true;
    }
    
    override func addSubviews() {
        super.addSubviews();
        self.addSubview(leadLabel);
        self.addSubview( pinInput );
    }
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints();
        leadLabel.topAlignWithParent(constant: 20.0);
        leadLabel.centerXAlignWithParent();
        leadLabel.setFixedWidth(constant: 274.0);
        
        pinInput.placeBelow(toItem: leadLabel, constant: 20.0);
        pinInput.centerXAlignWithParent();
        pinInput.bottomAlignWithParent();
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
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }) )
        
        self.present(alertController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
