//
//  AuthorizeDeviceViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 03/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

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
        let view = OstUIKit.linkButton()
        view.setTitle("Recover with PIN", for: .normal);
        return view;
    }()
    
    let infoTextForRecovery: UILabel = {
        let label = OstUIKit.leadLabel()
        label.text = "Don’t have a secondary device or mnemonics?"
        return label
    }()
    
    //MAKR: - View LC
    override func getNavBarTitle() -> String {
        return "Authorize Device"
    }
    
    override func getLeadLabelText() -> String {
        return "We notice that this is not an authorized device. Please recover your wallet from the following options."
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MAKR: - Create Views
    
    override func addSubviews() {
        super.addSubviews()
        addSubview(authorizeViaQRButton)
        addSubview(authorizeViaMnemonicsButton)
        addSubview(infoTextForRecovery)
        addSubview(recoverWithPinButton)
        
       
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
        recoverWithPinButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    //MARK: - Button Actions
    
    @objc func authorizeViaQRButtonTapped(_ sender: Any?) {
        let authorizeViaQRVC = ShowQRCodeViewController()
        authorizeViaQRVC.pushViewControllerOn(self)
    }
    
    @objc func authorizeViaMnemonicsButtonTapped(_ sender: Any?) {
        let authorizeViaMnemonicsVC = AuthorizeDeviceViaMnemonicsViewController()
        authorizeViaMnemonicsVC.subscribeToCallback = {[weak self] workflowCallbacks in
            OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowCallbacks.workflowId, listner: self!)
        }
        
        authorizeViaMnemonicsVC.pushViewControllerOn(self, animated: true)
    }
    
    @objc func recoverWithPinButton(_ sender: Any?) {
        
        let initiateDeviceRecovery = InitiateDeviceRecoveryViewController()
        initiateDeviceRecovery.subscribeToCallback = {[weak self] workflowCallbacks in
            OstSdkInteract.getInstance.subscribe(forWorkflowId: workflowCallbacks.workflowId, listner: self!)
        }
        
        initiateDeviceRecovery.pushViewControllerOn(self)
    }
    
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        super.requestAcknowledged(workflowId: workflowId, workflowContext: workflowContext, contextEntity: contextEntity)
        onRequestAcknowledged(workflowContext: workflowContext, contextEntity: contextEntity)
    }
    
    func onRequestAcknowledged(workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if workflowContext.workflowType == .initiateDeviceRecovery,
            let entity = contextEntity.entity as? OstDevice,
            let currentDevice = CurrentUserModel.getInstance.currentDevice {
            
            if entity.userId?.caseInsensitiveCompare(currentDevice.userId ?? "" ) == .orderedSame
                && entity.status?.caseInsensitiveCompare(ManageDeviceViewController.DeviceStatus.authorizing.rawValue) == .orderedSame{
                
                self.navigationController?.popToRootViewController(animated: true)
            }
        }else if workflowContext.workflowType == .authorizeDeviceWithMnemonics,
                    let entity = contextEntity.entity as? OstDevice,
                    let currentDevice = CurrentUserModel.getInstance.currentDevice {
            
            if entity.address?.caseInsensitiveCompare(currentDevice.address ?? "" ) == .orderedSame
                && (entity.isStatusAuthorizing || entity.isStatusAuthorized) {
                
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
}
