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
            guard let qrCode = try OstWalletSdk.getAddDeviceQRCode(userId: ostUserId) else {
                return
            }
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
        addSubview(qrCodeImageView)
        addSubview(containerView)
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
    
    //MARK: - Add Constraint
    override func addLayoutConstraints() {
        super.addLayoutConstraints()
        addQRImageView()
        addAddressTextConstraints()
        addAddressConstraints()
        addContainerViewConstraints()
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
}
