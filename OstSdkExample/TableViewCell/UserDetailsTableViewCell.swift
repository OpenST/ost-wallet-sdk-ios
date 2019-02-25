//
//  UserDetailsTableViewCell.swift
//  Example
//
//  Created by aniket ayachit on 09/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit

class UserDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var userTitleBackgroundView: UIView!
    @IBOutlet weak var userMobileNumberLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userTitleLabel: UILabel!
    
    var userDetails: [String: Any] = [:]
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setUserDetails(_ userDetails: [String: Any]) {
        self.userDetails = userDetails
        userTitleBackgroundView.backgroundColor = getPastalColour()
        userMobileNumberLabel.text = (userDetails["mobile_number"] as! String)
        userNameLabel.text = (userDetails["username"] as! String)
        userTitleLabel.text = getInitialForName()
    }
    
    func getInitialForName() -> String {
        return (userDetails["username"] as! String).substr(0, 1) ?? ""
    }
    
    func getPastalColour() -> UIColor {
        let mobileNumber = userDetails["mobile_number"] as! String
        
        if mobileNumber.hasSuffix("1") || mobileNumber.hasSuffix("4") || mobileNumber.hasSuffix("7") {
        
            return color(r: 156, g: 38, b: 6, a: 1)
            
        }else if mobileNumber.hasSuffix("2") || mobileNumber.hasSuffix("5") || mobileNumber.hasSuffix("8") {
            return color(r: 156, g: 38, b: 6, a: 1)
        
        }else if mobileNumber.hasSuffix("3") || mobileNumber.hasSuffix("6") || mobileNumber.hasSuffix("9") {
            return color(r: 6, g: 88, b: 156, a: 1)
        }else {
            return color(r: 129, g: 6, b: 156, a: 1)
        }
    }
    
    func color(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat) -> UIColor {
        return UIColor(red: (r/255.0), green: (g/255.0), blue: (b/255.0), alpha: a)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
