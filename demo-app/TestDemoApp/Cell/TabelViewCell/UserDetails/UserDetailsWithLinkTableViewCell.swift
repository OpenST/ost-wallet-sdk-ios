/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

class UserDetailsWithLinkTableViewCell: UserDetailsWithCopyBtnTableViewCell {

    static var userDetailsWithLinkCellIdentifier: String {
        return String(describing: UserDetailsWithLinkTableViewCell.self)
    }
    
    override func getButtonImage() -> UIImage {
        return UIImage(named: "viewIcon")!
    }
    
    var userDetailsWithLink: UserDetailsWithLinkViewModel! {
        didSet {
            setupUserDetails(details: userDetailsWithLink)
        }
    }
    
    func setupUserDetails(details: UserDetailsWithLinkViewModel) {
        super.setupUserDetails(details: userDetailsWithLink)
        
        let textRange = NSMakeRange(0, infoText.text?.count ?? 0)
        let attributedText = NSMutableAttributedString(string: infoText.text ?? "")
        attributedText.addAttribute(NSAttributedString.Key.underlineStyle , value: NSUnderlineStyle.single.rawValue, range: textRange)
        // Add other attributes if needed
        self.infoText.attributedText = attributedText
    }
    
    override func buttonTapped(_ sender: Any?) {
        if let urlString =  userDetailsWithLink.urlString {
            let webVC = WKWebViewController()
            webVC.title = "OST View"
            webVC.urlString = urlString
            webVC.showVC()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            buttonTapped(nil)
        }
    }
}
