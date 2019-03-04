//
//  SignupViewController.swift
//  Example
//
//  Created by aniket ayachit on 08/02/19.
//  Copyright © 2019 aniket ayachit. All rights reserved.
//

import UIKit
import OstSdk

class SignupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var userDetailsTableView: UITableView!

    let userDetailsReuseIdentifier = "userDetailsReuseIdentifier"
    
    let QRCodeFlow = "signupToShowQR"
    
    var username: String = ""
    var mobileNumber: String = ""
    var mappyUser: [String: Any]? = nil
    
    var userId: String = ""
    var tokenId: String = ""
    var mappyUserId: String = ""
    
    @IBAction func flowButtonTapped(_ sender: Any) {
        
        
    }
    var userDetailsTabelArray: [[String: Any]] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        createUser()
    }
    
    func userParam() -> [String: Any]{
        return ["username": username, "mobile_number": mobileNumber]
    }
    
    func createUser() {
        MappyUser().createUser(params: userParam(), onSuccess: { (userObj) in
            self.mappyUser = userObj!
            SharedDatabase.sharedInstance.insertUser(userObj!)
            self.userDetailsTabelArray.append(userObj!)
            self.relaodTable()
            self.createOstUser(for: (userObj!["_id"] as! String))
        }) { (failureObj) in
            print(failureObj as Any)
        }
    }
    
    func createOstUser(for userId: String) {
        MappyUser().createOstUser(for: userId, onSuccess: { (ostUserObj) in
           self.parseUser(ostUserObj!)
        }) { (failureObj) in
            print(failureObj as Any)
        }
    }
    
    func parseUser(_ ostUserObj: [String: Any]) {
        do {
            self.userId = ostUserObj["user_id"] as! String
            self.tokenId = ostUserObj["token_id"] as! String
            self.mappyUserId = ostUserObj["app_user_id"] as! String
            
            try SetupDevice(userId: ostUserObj["user_id"] as! String, tokenId: ostUserObj["token_id"] as! String, mappyUserId: (ostUserObj["app_user_id"] as! String)).perform()
            

        }catch let error{
            Logger.log(message: "parseUser", parameterToPrint: error)
        }
    }
    
    func relaodTable(withData tableDataArray: [[String: Any]]? = nil) {
        if tableDataArray != nil {
            userDetailsTabelArray = tableDataArray!
        }
        userDetailsTableView.reloadData()
    }
    
}

extension SignupViewController {
    //MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userDetailsTabelArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UserDetailsTableViewCell = tableView.dequeueReusableCell(withIdentifier: userDetailsReuseIdentifier, for: indexPath) as! UserDetailsTableViewCell
        
        let userDetails = userDetailsTabelArray[indexPath.row]
        cell.setUserDetails(userDetails)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
}
