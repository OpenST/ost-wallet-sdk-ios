//
//  ShowQRCodeViewController.swift
//  TestDemoApp
//
//  Created by aniket ayachit on 01/05/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class ShowQRCodeViewController: BaseSettingOptionsViewController {
    
    override func getNavBarTitle() -> String {
        return "Device QR"
    }
    
    override func getLeadLabelText() -> String {
        return "Please scan the QR Code from your old device to authorize this device"
    }
    
    //MARK: - Themers
    var deviceInfoThemer = OstTheme.leadLabel
    
    //MARK: - Components
    var addressTextLabel: UILabel? = nil
    var addressLabel: UILabel? = nil
    var checkStatusButton: UIButton? = nil
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.color(67, 139, 173, 0.1)
        view.layer.cornerRadius = 5
        
        return view
    }()
    
    var qrCodeImageView: UIImageView = {
        var qrCodeImageView = UIImageView(image: nil)
        qrCodeImageView.translatesAutoresizingMaskIntoConstraints = false
        return qrCodeImageView
    }()
    
    
    //MARK: - View LC
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            guard let ostUserId = CurrentUserModel.getInstance.ostUserId else {return}
            let qrCode = try OstWalletSdk.getAddDeviceQRCode(userId: ostUserId)
            let multiplyingFactor = (qrCodeImageView.frame.height/100)+1
            let transform: CGAffineTransform  = CGAffineTransform(scaleX: multiplyingFactor, y: multiplyingFactor);
            let output: CIImage = qrCode.transformed(by: transform)
            qrCodeImageView.image = UIImage(ciImage: output)
        }catch {
            
        }
    }
    
    //MARK: - Add Subview
    override func addSubviews() {
        super.addSubviews()
        createAddressTextLabel()
        createAddressLabel()
        createCheckStatueButton()
        
        addSubview(qrCodeImageView)
        addSubview(containerView)
        addSubview(checkStatusButton!)
    }
    
    func createAddressTextLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Device Address"
        deviceInfoThemer.apply(label)
        
        label.font = deviceInfoThemer.getFontProvider().get(size: 12)
        addressTextLabel = label
        containerView.addSubview(label)
    }
    
    func createAddressLabel() {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        let ostUser = OstWalletSdk.getUser(CurrentUserModel.getInstance.ostUserId!)
        let device = ostUser?.getCurrentDevice()
        label.text = device?.address ?? ""
        deviceInfoThemer.apply(label)
        label.font = deviceInfoThemer.getFontProvider().get(size: 12).bold()
        
        addressLabel = label
        containerView.addSubview(label)
    }
    
    func createCheckStatueButton() {
        let button = OstUIKit.primaryButton()
        button.setTitle("Check Device Status", for: .normal)
        button.addTarget(self, action: #selector(self.checkStatusButtonTapped(_ :)), for: .touchUpInside)
        checkStatusButton = button
    }
    
    
    //MARK: - Add Constraint
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addQRImageView()
        addAddressTextConstraints()
        addAddressConstraints()
        addContainerViewConstraints()
        addCheckStatusButtonConstraitns()
    }
    
    func addQRImageView() {
        qrCodeImageView.placeBelow(toItem: leadLabel)
        qrCodeImageView.centerXAlignWithParent()
        qrCodeImageView.setW375Width(width: 216)
        qrCodeImageView.setAspectRatio(widthByHeight: 1)
    }
    
    func addAddressTextConstraints() {
        addressTextLabel?.topAlignWithParent(multiplier: 1, constant: 10)
        addressTextLabel?.applyBlockElementConstraints(horizontalMargin: 25)
    }
    
    func addAddressConstraints() {
        addressLabel?.placeBelow(toItem: addressTextLabel!, multiplier: 1, constant: 4)
        addressLabel?.applyBlockElementConstraints(horizontalMargin: 20)
    }
    
    func addContainerViewConstraints() {
        containerView.placeBelow(toItem: qrCodeImageView, multiplier: 1, constant: 25)
        containerView.applyBlockElementConstraints(horizontalMargin: 25)
        containerView.bottomAlign(toItem: addressLabel!, multiplier: 1, constant: 8)
    }
    
    func addCheckStatusButtonConstraitns() {
        checkStatusButton?.placeBelow(toItem: containerView, multiplier: 1, constant: 20)
        checkStatusButton?.applyBlockElementConstraints()
    }
    
    //MARK: - Action
    @objc func checkStatusButtonTapped(_ sender: Any?) {
        progressIndicator = OstProgressIndicator(textCode: .checkDeviceStatus)
        progressIndicator?.show()
        OstWalletSdk.setupDevice(userId: CurrentUserModel.getInstance.ostUserId!,
                                 tokenId: CurrentEconomy.getInstance.tokenId!,
                                 delegate: self.workflowDelegate)
    }
    
    //MAKR: - OstSdkInteract Delegate
    override func flowInterrupted(workflowId: String, workflowContext: OstWorkflowContext, error: OstError) {
        progressIndicator?.hide()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {[weak self] in
            let alert = UIAlertController(title: "Something went wrong",
                                      message: error.errorMessage,
                                      preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self?.present(alert, animated: true, completion: nil)
        }
    }
    
    override func requestAcknowledged(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        processIfRequired(workflowContext: workflowContext, contextEntity: contextEntity)
    }
    
    override func flowComplete(workflowId: String, workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        processIfRequired(workflowContext: workflowContext, contextEntity: contextEntity)
    }
    
    func processIfRequired(workflowContext: OstWorkflowContext, contextEntity: OstContextEntity) {
        if workflowContext.workflowType == .setupDevice {
            if let currentDevice = CurrentUserModel.getInstance.currentDevice,
                (currentDevice.isStatusRecovering
                    || currentDevice.isStatusAuthorized) {
                
                progressIndicator?.progressText = "Signing into your wallet…"
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {[weak self] in
                    self?.navigationController?.popToRootViewController(animated: true)
                    self?.progressIndicator?.hide()
                }
            }else {
                progressIndicator?.hide()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {[weak self] in
                
                    let alert = UIAlertController(title: "Device not Authorized",
                                                  message: "Please authorize this device from your other authorized device",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self?.present(alert, animated: false, completion: nil)
                }
            }
        }
    }
}
