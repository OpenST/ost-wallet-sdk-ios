/*
 Copyright © 2019 OST.com Inc
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 */

import UIKit

class UserDetailsWithCopyBtnTableViewCell: UserDetailsTableViewCell {

    var progressIndicator: OstProgressIndicator? = nil
    
    static var userDetailsWithCopyCellIdentifier: String {
        return String(describing: UserDetailsWithCopyBtnTableViewCell.self)
    }
    
    var copyButton: UIButton = {
        let view = UIButton()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    //MARK: - Create Views
    override func createViews() {
        super.createViews()
        copyButton.setImage(getButtonImage(), for: .normal)
        copyButton.addTarget(self, action: #selector(self.buttonTapped(_:)), for: .touchUpInside)
        
        addSubview(copyButton)
    }
    
    func getButtonImage() -> UIImage {
        return UIImage(named: "CopyImage")!
    }
    
    //MARK: - Add Constraints
    override func applyConstraints() {
        super.applyConstraints()
        addCopyButtonConstraints()
    }
    
    override func infoLabelRightAnchor() {
        infoText.rightAnchor.constraint(equalTo: self.copyButton.leftAnchor, constant: -14).isActive = true
    }
    
    func addCopyButtonConstraints() {
        guard let parent = copyButton.superview else {return}
        copyButton.rightAnchor.constraint(equalTo: parent.rightAnchor, constant: -8).isActive = true
        copyButton.widthAnchor.constraint(equalToConstant: 44).isActive =  true
        copyButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        copyButton.centerYAnchor.constraint(equalTo: infoText.centerYAnchor).isActive = true
    }
    
    @objc func buttonTapped(_ sender: Any?) {
        UIPasteboard.general.string = infoText.text ?? ""
        
        progressIndicator = OstProgressIndicator()
        progressIndicator?.showSuccessAlert(withTitle: "\(userDetails.title) copied.",
            duration: 1,
            onCompletion: nil)
    }
}
