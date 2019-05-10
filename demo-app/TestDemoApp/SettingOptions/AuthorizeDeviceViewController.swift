//
//  AuthorizeDeviceViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 03/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class AuthorizeDeviceViewController: BaseSettingOptionsViewController {

    //MAKR: - Components
    let authorizeViaQRButton: UIButton = {
        let view = OstUIKit.primaryButton();
        view.setTitle("Authorize with QR", for: .normal);
        return view;
    }()
    let authorizeViaMnemonicsButton: UIButton = {
        let view = OstUIKit.secondaryButton()
        view.setTitle("Authorize with Mnemonics", for: .normal);
        return view;
    }()
    let recoverWithPinButton: UIButton = {
        let view = OstUIKit.secondaryButton()
        view.setTitle("Recover with PIN", for: .normal);
        return view;
    }()
    
    let infoTextForRecovery: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Don’t have a secondary device or mnemonics?"
        return label
    }()
    
    //MARK: Themer
    var infoTextForRecoveryThemer = OstTheme.leadLabel
    
    //MAKR: - View LC
    override func getNavBarTitle() -> String {
        return "Authorize Device"
    }
    
    override func getLeadLabelText() -> String {
        return "We notice that this is not an authorized device. Please recover your wallet from the following options."
    }
    
    //MAKR: - Create Views
    
    override func addSubviews() {
        super.addSubviews()
        addSubview(authorizeViaQRButton)
        addSubview(authorizeViaMnemonicsButton)
        addSubview(recoverWithPinButton)
        addSubview(infoTextForRecovery)

        infoTextForRecoveryThemer.apply(infoTextForRecovery)
       
        weak var weakSelf = self
        authorizeViaQRButton.addTarget(weakSelf, action: #selector(weakSelf!.authorizeViaQRButtonTapped(_:)), for: .touchUpInside)
        authorizeViaMnemonicsButton.addTarget(weakSelf, action: #selector(weakSelf!.authorizeViaMnemonicsButtonTapped(_:)), for: .touchUpInside)
        recoverWithPinButton.addTarget(weakSelf, action: #selector(weakSelf!.recoverWithPinButton(_:)), for: .touchUpInside)
    }
    
    //MARK: - Apply Constraints
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addAuthorizeViaQRButtonConstraints()
        addAuthorizeViaMnemonicsButtonConstraints()
        addInfoTextForRecoveryConstraints()
        addRecoverWithPinButtonConstraints()
    }
    
    func addAuthorizeViaQRButtonConstraints() {
        authorizeViaQRButton.placeBelow(toItem: leadLabel)
        authorizeViaQRButton.setW375Width(width: 315)
        authorizeViaQRButton.setAspectRatio(width: 315, height: 50)
        authorizeViaQRButton.centerXAlignWithParent()
    }
    
    func addAuthorizeViaMnemonicsButtonConstraints() {
        authorizeViaMnemonicsButton.placeBelow(toItem: authorizeViaQRButton)
        authorizeViaMnemonicsButton.setW375Width(width: 315)
        authorizeViaMnemonicsButton.setAspectRatio(width: 315, height: 50)
        authorizeViaMnemonicsButton.centerXAlignWithParent()
    }
    
    func addInfoTextForRecoveryConstraints() {
        infoTextForRecovery.applyBlockElementConstraints()
        infoTextForRecovery.bottomFromTopAlign(toItem: recoverWithPinButton,
                                               constant: -4)                      
    }
    
    func addRecoverWithPinButtonConstraints() {
        recoverWithPinButton.applyBlockElementConstraints()
        recoverWithPinButton.bottomAlignWithParent(multiplier: 1, constant: -38)
    }
    
    //MARK: - Button Actions
    
    @objc func authorizeViaQRButtonTapped(_ sender: Any?) {
        let authorizeViaQRVC = QRScannerViewController()
        authorizeViaQRVC.pushViewControllerOn(self)
    }
    
    @objc func authorizeViaMnemonicsButtonTapped(_ sender: Any?) {
        let authorizeViaMnemonicsVC = AuthorizeDeviceViaMnemonicsViewController()
        authorizeViaMnemonicsVC.pushViewControllerOn(self, animated: true)
    }
    
    @objc func recoverWithPinButton(_ sender: Any?) {
        let currentUser = CurrentUserModel.getInstance
        _ = OstSdkInteract.getInstance.resetPin(userId: currentUser.ostUserId!,
                                                passphrasePrefixDelegate: currentUser,
                                                presenter: self)
    }
}
