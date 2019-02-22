//
//  LoginViewController.swift
//  Example
//
//  Created by aniket ayachit on 08/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk

class LoginViewController: SignupViewController {
    
    var user: [String: Any]? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        validateUser()
        // Do any additional setup after loading the view.
    }
    
    override func createUser() { }
    
    func validateUser() {
        MappyUser().validateUser(params: userParam(), onSuccess: { (userObj) in
            self.user = userObj
            self.getUsersList()
            
            OstSdk.setupDevice(userId: self.user!["ost_user_id"]! as! String, tokenId: "1003", delegate: OstWorkFlowCallbackImplementation(mappyUserId: self.user!["_id"] as! String))
            
        }) { (failuarObj) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func getUsersList() {
        MappyUser().getAllUsers(onSuccess: { (succesObj) in
            let resultType = succesObj!["result_type"] as! String
            SharedDatabase.sharedInstance.insertUsers(succesObj![resultType] as! Array)
            self.relaodTable(withData: SharedDatabase.sharedInstance.getUserList())
        }) { (failuarObj) in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
