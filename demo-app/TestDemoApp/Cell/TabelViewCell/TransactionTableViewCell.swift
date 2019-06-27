//
//  DATransactionTableViewCell.swift
//  DemoApp
//
//  Created by aniket ayachit on 22/04/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstWalletSdk

class TransactionTableViewCell: UsersTableViewCell {
    static var transactionCellIdentifier: String {
        return String(describing: TransactionTableViewCell.self)
    }
    
    var transactionData: [String: Any]! {
        didSet {
            
            let displayName = transactionData["display_name"] as? String ?? ""
            let imageName = transactionData["image_name"] as? String ?? ""
            
            self.titleLabel?.text = displayName
            self.overlayImage.image = UIImage(named: imageName)
            
            let currentUserOstId = CurrentUserModel.getInstance.ostUserId ?? ""
            let fromUserId = transactionData["from_user_id"] as! String
            
            var amountVal = (ConversionHelper.toString(transactionData["amount"])!).toRedableFormat()
            amountVal = amountVal.toRoundUpTxValue()
            if currentUserOstId.compare(fromUserId) == .orderedSame {
                self.amountLabel.text = "- \(amountVal)"
                self.amountLabel.textColor = UIColor.color(155, 155, 155)
            }else {
                self.amountLabel.text = "+ \(amountVal)"
                self.amountLabel.textColor = UIColor.color(67, 139, 173)
            }
            
            let date = getDateFromTimestamp()
            self.balanceLabel?.text = date ?? ""
        }
    }
    
    func getDateFromTimestamp() -> String? {
        guard let unixTimestamp = transactionData["block_timestamp"] as? Double else {
            return Date().getDateWithTimeString()
        }
        let date = Date(timeIntervalSince1970: unixTimestamp)
    
        return date.getDateWithTimeString()
    }

    //MARK: - Components
    var overlayImage: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    var amountLabel: UILabel  = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .right
        label.font = OstTheme.fontProvider.get(size: 15).bold()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    //MARK: - AddViews
    override func createViews() {
        super.createViews()
        self.selectionStyle = .none
    }
    
    override func createInternalView() {
         self.circularView!.addSubview(overlayImage)
    }
    
    override func createSendButton() {
        self.addSubview(amountLabel)
    }
    
    //MARK: - Apply Constraints
    
    override func applyConstraints() {
        super.applyConstraints()
        addAmountLabelConstraints()
    }
    
    override func applyInitialLetterConstraints() {
        self.overlayImage.centerYAnchor.constraint(equalTo: self.circularView!.centerYAnchor).isActive = true
        self.overlayImage.centerXAnchor.constraint(equalTo: self.circularView!.centerXAnchor).isActive = true
        self.overlayImage.widthAnchor.constraint(equalToConstant: 45).isActive = true
        self.overlayImage.heightAnchor.constraint(equalTo: (self.overlayImage.widthAnchor)).isActive = true
    }
    
    override  func applyDetailsViewConstraints() {
        self.detailsContainerView?.translatesAutoresizingMaskIntoConstraints = false
        self.detailsContainerView?.leftAnchor.constraint(equalTo: self.circularView!.rightAnchor, constant: 8.0).isActive = true
        self.detailsContainerView?.rightAnchor.constraint(equalTo: self.amountLabel.leftAnchor, constant: -8.0).isActive = true
        self.detailsContainerView?.topAnchor.constraint(equalTo: circularView!.topAnchor, constant:4.0).isActive = true
        self.detailsContainerView?.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:-12.0).isActive = true
    }
    
    func addAmountLabelConstraints() {
        self.amountLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -18.0).isActive = true
        self.amountLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0.0).isActive = true
        self.amountLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 150.0).isActive = true
        self.amountLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
    }
}
