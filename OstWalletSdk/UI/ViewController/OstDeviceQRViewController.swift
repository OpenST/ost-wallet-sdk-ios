/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import Foundation

class OstDeviceQRViewController: OstBaseViewController {
    
    class func newInstance(qrCode: CIImage, for userId: String) -> OstDeviceQRViewController {
        let vc = OstDeviceQRViewController()
        vc.qrCode = qrCode
        vc.userId = userId
        
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
        view.backgroundColor = UIColor.color(248, 248, 248)
        return view
    }()
    
    let addressTextLabel: OstH2Label = OstH2Label(text: "Device Address")
    let deviceAddressLabel: OstH3Label = OstH3Label()
    var qrCode: CIImage? = nil
    var bottomConstraints: NSLayoutConstraint? = nil
    
    //MARK: - View LC
    override func configure() {
        super.configure()
        
        let viewConfig = OstContent.getShowDeviceQRVCConfig()
        titleLabel.updateAttributedText(data: viewConfig[OstContent.OstComponentType.titleLabel.getComponentName()],
                                        placeholders: viewConfig[OstContent.OstComponentType.placeholders.getComponentName()])
        
        leadLabel.updateAttributedText(data: viewConfig[OstContent.OstComponentType.leadLabel.getComponentName()],
                                        placeholders: viewConfig[OstContent.OstComponentType.placeholders.getComponentName()])
        
        self.shouldFireIsMovingFromParent = true;
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
        qrImageView.topAlign(toItem: leadLabel, multiplier: 1, constant: 10, relatedBy: .greaterThanOrEqual)
        qrImageView.centerXAlignWithParent()
        qrImageView.centerYAlignWithParent()
        qrImageView.setW375Width(width: 200)
        qrImageView.setAspectRatio(widthByHeight: 1)
        qrImageView.bottomAlign(toItem: addressContainer, multiplier: 1, constant: -10, relatedBy: .lessThanOrEqual)
    }
    
    func addAddressContainerConstraints() {
        addressContainer.topAlign(toItem: addressTextLabel, constant: -25)
        addressContainer.bottomAlignWithParent()
        addressContainer.leftAlignWithParent()
        addressContainer.rightAlignWithParent()
    }
    
    func addDeviceAddressConstraints() {
        if #available(iOS 11.0, *) {
            let safeArea = view.safeAreaLayoutGuide
            bottomConstraints = deviceAddressLabel.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor,
                                                                           constant: -25)
            bottomConstraints!.isActive = true
        }else {
            deviceAddressLabel.bottomAlignWithParent(constant: -25)
        }
            
        deviceAddressLabel.leftAlignWithParent(multiplier: 1.0, constant: 20)
        deviceAddressLabel.rightAlignWithParent(multiplier: 1.0, constant: -20)
    }
    
    func addAddressLabelConstraints() {
        addressTextLabel.bottomFromTopAlign(toItem: deviceAddressLabel, constant: -4)
        addressTextLabel.leftAlignWithParent(multiplier: 1.0, constant: 40)
        addressTextLabel.rightAlignWithParent(multiplier: 1.0, constant: -40)
    }
}
