/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit
import OstWalletSdk

class QRInfoLabel: UILabel {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    public func showAuthorizeDeviceInfo(ostDevice:OstDevice) {
        let deviceAddress = ostDevice.address!;
        self.numberOfLines = 0;
        self.text = " Would you like to authorize this Device? \n"
            + "\n - Address:" + deviceAddress
            + "\n\n\n *If you do not own the device, do not authorize it."
            + " Authorized devices can spend tokens, authorize other devices and"
            + " can also revoke your existing devices."
        self.sizeToFit();
        self.textColor = UIColor.white;
        self.superview?.backgroundColor = UIColor.init(red: 52.0/255.0, green: 68.0/255.0, blue: 91.0/255.0, alpha: 1.0);
    }
    
    public func showRevokeDeviceInfo(ostDevice:OstDevice) {
        let deviceAddress = ostDevice.address!;
        self.numberOfLines = 0;
        self.text = " Would you like to revoke this Device? \n"
            + "\n - Address:" + deviceAddress
            + "\n\n\n*Rovked devices can not spend tokens, can not authorize other devices and"
            + " can not also revoke your existing devices."
        self.sizeToFit();
        self.textColor = UIColor.white;
        self.superview?.backgroundColor = UIColor.init(red: 52.0/255.0, green: 68.0/255.0, blue: 91.0/255.0, alpha: 1.0);
    }
    
    public func showUserInfo() {
        let currentUser = CurrentUser.getInstance();
        let ostUser = try! OstWalletSdk.getUser(currentUser.ostUserId!)
        let ostCurrentDevice = ostUser!.getCurrentDevice()
        
        self.numberOfLines = 0;
        let notPresentText = "undefined"
        self.text = """
        User Id: \(ostUser!.id)
        Token Id: \(ostUser?.tokenId ?? notPresentText)
        Token Holder Id: \(ostUser?.tokenHolderAddress ?? notPresentText)
        Device Manager Address: \(ostUser?.deviceManagerAddress ?? notPresentText)
        User Status: \(ostUser?.status ?? notPresentText)
        
        Device Address: \(ostCurrentDevice?.address ?? notPresentText)
        Device Status: \(ostCurrentDevice?.status ?? notPresentText)
        """
        self.sizeToFit();
        self.textColor = UIColor.white;
        self.font = UIFont.systemFont(ofSize: 13)
        self.superview?.backgroundColor = UIColor.init(red: 52.0/255.0, green: 68.0/255.0, blue: 91.0/255.0, alpha: 1.0);
    }
    
    
    //To-Do: show transaction info.
    public func showTransactionInfo() {
        //TBD
    }
    
    public func showInvalidQRCode() {
        self.text = "Invalid QR Code."
        self.sizeToFit();
        self.textColor = UIColor.red;
        self.superview?.backgroundColor = UIColor.init(red: 231.0/255.0, green: 246.0/255.0, blue: 247.0/255.0, alpha: 1.0);
    }
    
        
        
}
