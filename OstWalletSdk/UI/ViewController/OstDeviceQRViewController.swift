/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstDeviceQRViewController: OstBaseScrollViewController {
    
    class func newInstance(qrCode: CIImage,
                           for userId: String,
                           checkStatusCallback: (() -> Void)?) -> OstDeviceQRViewController {
        let vc = OstDeviceQRViewController()
        vc.qrCode = qrCode
        vc.userId = userId
        vc.checkStatusCallback = checkStatusCallback
        
        return vc
    }
    
    //MARK: - Components
    let titleLabel: OstH1Label = OstH1Label()
    let leadLabel: OstH2Label = OstH2Label()
    let qrImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    let addressContainer: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = UIColor.color(248, 248, 248)
        return view
    }()
    
    let addressTextLabel: OstC1Label = {
        let view =  OstC1Label(text: "Device Address")
        view.textAlignment = .center
        return view
    }()
    let deviceAddressLabel: OstH4Label = OstH4Label()
    let checkDeviceStatusButton: OstB1Button = OstB1Button(title: "")
    
    var qrCode: CIImage? = nil
    var checkStatusCallback: (() -> Void)? = nil
    
    //MARK: - View LC
    override func configure() {
        super.configure()
        
        let viewConfig = OstContent.getShowDeviceQRVCConfig()
        titleLabel.updateAttributedText(data: viewConfig[OstContent.OstComponentType.titleLabel.getComponentName()],
                                        placeholders: viewConfig[OstContent.OstComponentType.placeholders.getComponentName()])
        
        leadLabel.updateAttributedText(data: viewConfig[OstContent.OstComponentType.leadLabel.getComponentName()],
                                        placeholders: viewConfig[OstContent.OstComponentType.placeholders.getComponentName()])
        
        checkDeviceStatusButton.setTitle(getActionButtonText(viewConfig), for: .normal)
        checkDeviceStatusButton.addTarget(self, action: #selector(checkDeviceStatusButtonTapped(_:)), for: .touchUpInside)
        
        self.shouldFireIsMovingFromParent = true;
    }
    
    func getActionButtonText(_ viewConfig: [String: Any]) -> String {
        if let actionButton = viewConfig["action_button"] as? [String: Any],
            let text = actionButton["text"] as? String {
                
            return text
        }
        return ""
    }
    
    @objc func checkDeviceStatusButtonTapped(_ sender: Any) {
       checkStatusCallback?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let user = OstWalletSdk.getUser(userId!),
            let currentDevice = user.getCurrentDevice() {
        
            deviceAddressLabel.text = currentDevice.address ?? ""
        }
        
        let multiplyingFactor = CGFloat(3)
        let transform: CGAffineTransform  = CGAffineTransform(scaleX: multiplyingFactor, y: multiplyingFactor);
        let output: CIImage = qrCode!.transformed(by: transform)
        qrImageView.image = UIImage(ciImage: output)
    }
    
    //MARK: - Add Subview
    override func addSubviews() {
        super.addSubviews()
        
        self.addSubview(titleLabel)
        self.addSubview(leadLabel)
        self.addSubview(qrImageView)
        self.addSubview(addressContainer)
        addressContainer.addSubview(addressTextLabel)
        addressContainer.addSubview(deviceAddressLabel)
        
        self.addSubview(checkDeviceStatusButton)
        
        let lastView = checkDeviceStatusButton
        lastView.bottomAlignWithParent()
    }
    
    //MARK: - Apply Constraints
    
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        
        addTitleLabelConstraints()
        addLeadLabelLayoutConstraints()
        addQRImageConstraints()
        addAddressContainerConstraints()

        addDeviceAddressConstraints()
        addAddressLabelConstraints()
        
        addCheckDeviceStatusConstraints()
    }
    
    func addTitleLabelConstraints() {
        titleLabel.topAlignWithParent(multiplier: 1, constant: 20)
        titleLabel.applyBlockElementConstraints()
    }
    
    func addLeadLabelLayoutConstraints() {
        leadLabel.placeBelow(toItem: titleLabel)
        leadLabel.applyBlockElementConstraints(horizontalMargin: 40)
    }
    
    func addQRImageConstraints() {
        qrImageView.placeBelow(toItem: leadLabel, multiplier: 1, constant: 25)
        qrImageView.centerXAlignWithParent()
        qrImageView.setW375Width(width: 200)
        qrImageView.setAspectRatio(widthByHeight: 1)
    }
    
    func addAddressContainerConstraints() {
        addressContainer.placeBelow(toItem: qrImageView, constant: 25)
        addressContainer.leftAlignWithParent(multiplier: 1, constant: 25)
        addressContainer.rightAlignWithParent(multiplier: 1, constant: -25)
    }
    
    func addAddressLabelConstraints() {
        addressTextLabel.topAlign(toItem: addressContainer, constant: 10)
        addressTextLabel.leftAlignWithParent(multiplier: 1.0, constant: 10)
        addressTextLabel.rightAlignWithParent(multiplier: 1.0, constant: -10)
    }
    
    func addDeviceAddressConstraints() {
        deviceAddressLabel.placeBelow(toItem: addressTextLabel, constant: 4)
        deviceAddressLabel.leftAlignWithParent(multiplier: 1.0, constant: 10)
        deviceAddressLabel.rightAlignWithParent(multiplier: 1.0, constant: -10)
        deviceAddressLabel.bottomAlignWithParent(constant: -10)
    }
    
    func addCheckDeviceStatusConstraints() {
        checkDeviceStatusButton.placeBelow(toItem: addressContainer, constant: 25)
        checkDeviceStatusButton.leftAlignWithParent(multiplier: 1, constant: 25)
        checkDeviceStatusButton.rightAlignWithParent(multiplier: 1, constant: -25)
    }
}
